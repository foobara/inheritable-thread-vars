class Thread
  if const_defined?(:ThreadParent)
    raise "Thread::ThreadParent has already been declared elsewhere. Bailing out instead of clobbering it!"
  end

  module ThreadParent
    module ThreadClassExtensions
      def new(...)
        parent = Thread.current

        super.tap do |thread|
          if thread.instance_variable_defined?(:@thread_parent)
            raise "@thread_parent has already been declared elsewhere. Bailing out instead of clobbering it!"
          end

          thread.instance_variable_set("@thread_parent", parent)
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
