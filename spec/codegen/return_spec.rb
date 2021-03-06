require 'spec_helper'

describe 'Code gen: return' do
  it "codegens return" do
    run('def foo; return 1; end; foo').to_i.should eq(1)
  end

  it "codegens return followed by another expression" do
    run('def foo; return 1; 2; end; foo').to_i.should eq(1)
  end

  it "codegens return inside if" do
    run('def foo; if true; return 1; end; 2; end; foo').to_i.should eq(1)
  end

  it "return from function with union type" do
    run('def foo; return 1 if true; 1.1; end; foo.to_i').to_i.should eq(1)
  end

  it "return union" do
    run('def foo; true ? return 1 : return 1.1; end; foo.to_i').to_i.should eq(1)
  end

  it "return from function with nilable type" do
    run('require "nil"; require "reference"; def foo; return Reference.new if true; end; foo.nil?').to_b.should be_false
  end

  it "return from function with nilable type 2" do
    run('require "nil"; require "reference"; def foo; return Reference.new if 1 == 1; end; foo.nil?').to_b.should be_false
  end

  it "returns empty from function" do
    run(%q(
      class Nil; def to_i; 0; end; end
      def foo(x)
        return if x == 1
        1
      end

      foo(2).to_i
    )).to_i.should eq(1)
  end
end
