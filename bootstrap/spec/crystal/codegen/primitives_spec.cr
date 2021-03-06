require "../../spec_helper"

describe "Code gen: primitives" do
  it "codegens bool" do
    run("true").to_b.should be_true
    run("false").to_b.should be_false
  end

  it "codegens int" do
    run("1").to_i.should eq(1)
  end

  it "codegens long" do
    run("1_i64").to_i.should eq(1)
  end

  it "codegens char" do
    run("'a'").to_i.should eq('a'.ord)
  end

  it "codegens f32" do
    run("2.5_f32").to_f32.should eq(2.5_f32)
  end

  it "codegens f64" do
    run("2.5_f64").to_f64.should eq(2.5_f64)
  end

  it "codegens string" do
    run(%("foo")).to_string.should eq("foo")
  end
end
