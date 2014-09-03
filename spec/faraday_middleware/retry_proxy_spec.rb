require 'spec_helper'

RSpec.describe FaradayMiddleware::RetryProxy do
  let(:app) { lambda{ |env| env } }
  let(:request) { {} }
  let(:env) { {request: request, body: nil} }
  let(:error) { Faraday::Error::TimeoutError.new }
  let(:options) { nil }
  subject { described_class.new app, *Array(options) }

  describe "#call" do
    let(:request) { {proxy: ['x', 'y', 'z']} }
    context "all proxies are dead" do
      let(:app) { lambda{ |env| raise error } }
      it "retries with proxy and raises an error" do
        expect {
          subject.call(env)
        }.to raise_error(error)
      end
    end
    context "some of the proxies are dead" do
      let(:app) { idx = 0; lambda{ |env| idx += 1; raise error if idx == 1 } }
      it "retries with proxy" do
        expect {
          subject.call(env)
        }.not_to raise_error
      end
    end
    context "request succeeds" do
      it "does not retry with proxy" do
        expect {
          subject.call(env)
        }.not_to raise_error
      end
    end
    context "no proxy" do
      let(:request) { {} }
      it "does not retry" do
        expect(app).to receive(:call) do |env|
          expect(env[:request][:proxy]).to eq nil
        end
        subject.call(env)
      end
    end
    context "interval option" do
      let(:options) { [{interval: 0.5}] }
      let(:app) { idx = 0; lambda{ |env| idx += 1; raise error if idx == 1 } }
      it "retries with interval" do
        expect(subject).to receive(:sleep).with(0.5).and_return nil
        subject.call(env)
      end
      context "interval_randomness option" do
        let(:options) { [{interval: 0.5, interval_randomness: 0.5}] }
        let(:app) { idx = 0; lambda{ |env| idx += 1; raise error if idx == 1 } }
        it "retries with interval" do
          expect(subject).to receive(:sleep) do |time|
            expect(time).to be_within(0.5).of(1)
          end
          subject.call(env)
        end
      end
    end
  end
  describe "#normalize_proxies" do
    it "returns a proxy as an array" do
      proxies = subject.normalize_proxies('a')
      expect(proxies).to eq [{uri: 'a', user: nil, password: nil}]
    end
    it "returns an array of proxies" do
      proxies = subject.normalize_proxies(['a', 'b'])
      expect(proxies).to eq [{uri: 'a', user: nil, password: nil}, {uri: 'b', user: nil, password: nil}]
    end
    context "nil" do
      it "returns empty array" do
        proxies = subject.normalize_proxies(nil)
        expect(proxies).to eq []
      end
    end
    context "empty string" do
      it "returns empty array" do
        proxies = subject.normalize_proxies(nil)
        expect(proxies).to eq []
      end
    end
    context "proc" do
      it "returns a proxy from the proc as an array" do
        proxies = subject.normalize_proxies(lambda{ |env| 'a' })
        expect(proxies).to eq [{uri: 'a', user: nil, password: nil}]
      end
      it "returns an array of proxies from the proc as an array" do
        proxies = subject.normalize_proxies(lambda{ |env| ['a', 'b'] })
        expect(proxies).to eq [{uri: 'a', user: nil, password: nil}, {uri: 'b', user: nil, password: nil}]
      end
    end
  end
end
