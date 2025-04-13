class Thread
  if const_defined?(:ThreadParent)
    raise "Thread::ThreadParent has already been declared elsewhere. Bailing out instead of clobbering it!"
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
            raise "@thread_parent has already been declared elsewhere. Bailing out instead of clobbering it!"
          end

          child.instance_variable_set("@thread_parent", parent)

          parent_inheritable_thread_locals = parent.instance_variable_get(:@inheritable_thread_locals)

          if parent_inheritable_thread_locals
            if child.instance_variable_defined?(:@inheritable_thread_locals)
              raise "@inheritable_thread_locals has already been declared elsewhere. " \
                    "Bailing out instead of clobbering it!"
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

    def foobara_var_get(...)
      Thread.current.foobara_var_get(...)
    end

    def foobara_var_set(...)
      Thread.current.foobara_var_set(...)
    end

    def foobara_with_var(...)
      Thread.current.foobara_with_var(...)
    end
  end

  if method_defined?(:thread_parent)
    raise "Thread#thread_parent has already been declared elsewhere. Bailing out instead of clobbering it!"
  end

  attr_reader :thread_parent

  # NOTE: because there's not a way to unset a thread variable, storing nil is used as deletion.
  # this means that a thread local variable with nil can't have any semantic meaning and should be
  # treated the same as if #thread_variable? had returned false.
  def foobara_var_get(var_name)
    @inheritable_thread_locals&.[](var_name.to_sym)
  end

  def foobara_var_set(var_name, value)
    @inheritable_thread_locals ||= {}
    @inheritable_thread_locals[var_name.to_sym] = value
  end

  def foobara_with_var(key, value, &block)
    old_value = foobara_var_get(key)

    begin
      foobara_var_set(key, value)
      block.call
    ensure
      foobara_var_set(key, old_value)
    end
  end
end
