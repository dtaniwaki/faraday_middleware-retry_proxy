require 'spec_helper'

RSpec.describe FaradayMiddleware::RetryProxy do
  let(:subject_klass) { FaradayMiddleware::RetryProxy }
  let(:app) { double }
  let(:request) { {} }
  let(:env) { {request: request, body: nil} }
  before do
    allow(app).to receive(:call)
  end
  subject { subject_klass.new app }

  describe "#call" do
    let(:request) { {proxy: ['x', 'y', 'z']} }
    let(:error) { Faraday::Error::TimeoutError.new }
    it "retries with proxy" do
      expect(app).to receive(:call).with(env).exactly(3).times.and_raise error
      expect {
        subject.call(env)
      }.to raise_error(error)
    end
    context "request succeeds" do
      it "does not retry with proxy" do
        expect(app).to receive(:call).with(env).exactly(1).times.and_return nil
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
      subject { subject_klass.new app, interval: 0.5 }
      it "retries with interval" do
        expect(app).to receive(:call).with(env).and_raise error
        expect(subject).to receive(:sleep).with(0.5).and_return nil
        subject.call(env)
      end
      context "interval_randomness option" do
        subject { subject_klass.new app, interval: 1, interval_randomness: 0.5 }
        it "retries with interval" do
          expect(app).to receive(:call).with(env).and_raise error
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
      expect(proxies).to eq ['a']
    end
    it "returns an array of proxies" do
      proxies = subject.normalize_proxies(['a', 'b'])
      expect(proxies).to eq ['a', 'b']
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
        expect(proxies).to eq ['a']
      end
      it "returns an array of proxies from the proc as an array" do
        proxies = subject.normalize_proxies(lambda{ |env| ['a', 'b'] })
        expect(proxies).to eq ['a', 'b']
      end
    end
  end
end
