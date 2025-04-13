class Thread
  if const_defined?(:ThreadParent)
    # :nocov:
    raise "Thread::ThreadParent has already been declared elsewhere. Bailing out instead of clobbering it!"
    # :nocov:
  end

  module ThreadParent
    # If we try to perform a simpler approach to setting the parent via overriding Thread#initialize,
    # we run into the following error:
    # ThreadError:
    #   uninitialized thread - check 'Thread#initialize'
    # So instead we attack it higher up in by prepending an override to Thread.new
    # and leaving Thread#initialize alone.
    module ThreadClassExtensions
      def new(*, **, &block)
        parent = Thread.current

        super do
          child = Thread.current

          if child.instance_variable_defined?(:@thread_parent)
            # :nocov:
            raise "@thread_parent has already been declared elsewhere. Bailing out instead of clobbering it!"
            # :nocov:
          end

          child.instance_variable_set("@thread_parent", parent)

          parent_inheritable_thread_locals = parent.instance_variable_get(:@inheritable_thread_locals)

          if parent_inheritable_thread_locals
            if child.instance_variable_defined?(:@inheritable_thread_locals)
              # :nocov:
              raise "@inheritable_thread_locals has already been declared elsewhere. " \
                    "Bailing out instead of clobbering it!"
              # :nocov:
            end

            child.instance_variable_set("@inheritable_thread_locals", parent_inheritable_thread_locals.dup)
          end

          block.call
        end
      end
    end
  end

  class << self
    prepend(ThreadParent::ThreadClassExtensions)

    %i[
      inheritable_thread_local_var_get
      inheritable_thread_local_var_set
      with_inheritable_thread_local_var
    ].each do |method_name|
      if method_defined?(method_name)
        # :nocov:
        raise "Thread.#{method_name} has already been declared elsewhere. Bailing out instead of clobbering it!"
        # :nocov:
      end
    end

    def inheritable_thread_local_var_get(...)
      Thread.current.inheritable_thread_local_var_get(...)
    end

    def inheritable_thread_local_var_set(...)
      Thread.current.inheritable_thread_local_var_set(...)
    end

    def with_inheritable_thread_local_var(...)
      Thread.current.with_inheritable_thread_local_var(...)
    end
  end

  %i[
    inheritable_thread_local_var_get
    inheritable_thread_local_var_set
    with_inheritable_thread_local_var
  ].each do |method_name|
    if method_defined?(method_name)
      # :nocov:
      raise "Thread##{method_name} has already been declared elsewhere. Bailing out instead of clobbering it!"
      # :nocov:
    end
  end

  # NOTE: because there's not a way to unset a thread variable, storing nil is used as deletion.
  # this means that a thread local variable with nil can't have any semantic meaning and should be
  # treated the same as if #thread_variable? had returned false.
  def inheritable_thread_local_var_get(var_name)
    @inheritable_thread_locals&.[](var_name.to_sym)
  end

  def inheritable_thread_local_var_set(var_name, value)
    @inheritable_thread_locals ||= {}
    @inheritable_thread_locals[var_name.to_sym] = value
  end

  def with_inheritable_thread_local_var(key, value, &block)
    old_value = inheritable_thread_local_var_get(key)

    begin
      inheritable_thread_local_var_set(key, value)
      block.call
    ensure
      inheritable_thread_local_var_set(key, old_value)
    end
  end
end
