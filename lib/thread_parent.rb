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
  def foobara_var_get(...)
    value = thread_variable_get(...)

    value.nil? ? thread_parent&.foobara_var_get(...) : value
  end

  def foobara_var_set(...)
    thread_variable_set(...)
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
