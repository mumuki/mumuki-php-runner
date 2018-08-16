require_relative './spec_helper'

describe PhpQueryHook do
  let(:hook) { PhpQueryHook.new }
  let(:file) { hook.compile(request) }
  let(:result) { hook.run!(file) }

  let(:okQuery) { 'foo()' }
  let(:okCode) { 'function foo() { return "bar"; }' }

  let(:extraCode) { '$extraVariable = 22;' }
  let(:okCodeOnExtra) { 'function foo() { global $extraVariable; return "bar".$extraVariable; }' }

  describe 'should pass on ok request' do
    let(:request) { qreq(okCode, okQuery) }
      it { expect(result).to eq ["bar", :passed] }
  end

  describe 'should have result on ok request with query dependent on extra' do
    let(:request) { qreq(okCodeOnExtra, okQuery, extraCode) }
    it { expect(result).to eq ["bar22", :passed] }
  end
end

