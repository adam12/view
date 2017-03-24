RSpec::Matchers.define :template_scope do |locals|
  match do |actual|
    locals == locals.map { |k,v| [k, actual.send(k)] }.to_h
  end
end

RSpec.describe Dry::View::Part do
  subject(:part) { described_class.new(name: name, value: value, renderer: renderer, context: context) }

  let(:name) { :user }
  let(:value) { double('value') }
  let(:context) { double('context') }
  let(:renderer) { double('renderer') }

  describe '#render' do
    before do
      allow(renderer).to receive(:lookup).with('_info').and_return '_info.html.erb'
      allow(renderer).to receive(:render)
    end

    it 'renders a partial with the part available in its scope' do
      part.render(:info)
      expect(renderer).to have_received(:render).with('_info.html.erb', template_scope(user: part))
    end

    it 'allows the part to be made available on a different name' do
      part.render(:info, as: :admin)
      expect(renderer).to have_received(:render).with('_info.html.erb', template_scope(admin: part))
    end

    it 'includes extra locals in the scope' do
      part.render(:info, extra_local: "hello")
      expect(renderer).to have_received(:render).with('_info.html.erb', template_scope(user: part, extra_local: "hello"))
    end
  end

  describe '#to_s' do
    before do
      allow(value).to receive(:to_s).and_return 'to_s on the value'
    end

    it 'delegates to the wrapped value' do
      expect(part.to_s).to eq 'to_s on the value'
    end
  end

  describe '#method_missing' do
    describe 'matching the value' do
      let(:context) { double(greeting: 'hello from context') }

      describe 'methods' do
        let(:value) { double(greeting: 'hello from value') }

        it 'calls a matching method on the value, in favour of a matching method on the context' do
          expect(part.greeting).to eq 'hello from value'
        end

        it 'forwards all arguments to the method' do
          allow(value).to receive(:farewell)

          blk = -> { }
          part.farewell "args here", &blk

          expect(value).to have_received(:farewell).with("args here", &blk)
        end
      end

      describe 'hash keys' do
        let(:value) { {greeting: 'hello from value hash'} }

        it 'returns a matching value from the value, in favour of a matching method on the context' do
          expect(part.greeting).to eq 'hello from value hash'
        end
      end
    end

    describe 'no matches' do
      it 'raises an error' do
        expect { part.greeting }.to raise_error(NoMethodError)
      end
    end
  end

  def itself_with(**overrides)
    described_class.new(
      {
        name: part._name,
        value: part._value,
        renderer: part._renderer,
        context: part._context,
      }.merge(overrides)
    )
  end
end
