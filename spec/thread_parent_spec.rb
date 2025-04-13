RSpec.describe Thread::ThreadParent do
  describe "#inheritable_thread_local_var_set and #inheritable_thread_local_var_get" do
    it "inherits from parent threads and overrides locally" do
      outer = Thread.new do
        Thread.inheritable_thread_local_var_set("test", "outer")
        expect(Thread.inheritable_thread_local_var_get("test")).to eq("outer")

        inner = Thread.new do
          expect(Thread.inheritable_thread_local_var_get("test")).to eq("outer")
          Thread.inheritable_thread_local_var_set("test", "inner")
          expect(Thread.inheritable_thread_local_var_get("test")).to eq("inner")
        end

        sleep 0.2
        expect(Thread.inheritable_thread_local_var_get("test")).to eq("outer")
        inner.join
        expect(Thread.inheritable_thread_local_var_get("test")).to eq("outer")
        expect(inner.inheritable_thread_local_var_get("test")).to eq("inner")
      end

      expect(Thread.inheritable_thread_local_var_get("test")).to be_nil
      outer.join
      expect(Thread.inheritable_thread_local_var_get("test")).to be_nil
    end
  end

  describe ".with_inheritable_thread_local_var" do
    it "gives a convenient way to set a variable, execute a block, and set it back" do
      expect(Thread.inheritable_thread_local_var_get("test")).to be_nil

      Thread.with_inheritable_thread_local_var("test", "initial") do
        expect(Thread.inheritable_thread_local_var_get("test")).to eq("initial")

        Thread.with_inheritable_thread_local_var("test", "new") do
          expect(Thread.inheritable_thread_local_var_get("test")).to eq("new")
        end

        expect(Thread.inheritable_thread_local_var_get("test")).to eq("initial")
      end

      expect(Thread.inheritable_thread_local_var_get("test")).to be_nil
    end
  end
end
