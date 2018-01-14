RSpec::Matchers.define :template_scope do |locals|
  match do |actual|
    locals == locals.map { |k,v| [k, actual.send(k)] }.to_h
  end
end

RSpec.describe Dry::View::Part do
  context 'with a renderer' do
    subject(:part) { described_class.new(name: name, value: value, renderer: renderer, context: context) }

    let(:name) { :user }
    let(:value) { double(:value) }
    let(:context) { double(:context) }
    let(:renderer) { spy(:renderer) }

    describe '#render' do
      it 'renders a partial with the part available in its scope' do
        part.render(:info)
        expect(renderer).to have_received(:partial).with(:info, template_scope(user: part))
      end

      it 'allows the part to be made available on a different name' do
        part.render(:info, as: :admin)
        expect(renderer).to have_received(:partial).with(:info, template_scope(admin: part))
      end

      it 'includes extra locals in the scope' do
        part.render(:info, extra_local: "hello")
        expect(renderer).to have_received(:partial).with(:info, template_scope(user: part, extra_local: "hello"))
      end
    end

    describe '#new' do
      let(:renderer) do
        Dry::View::Renderer.new(
          [Dry::View::Path.new(SPEC_ROOT.join('fixtures/templates'))],
          format: 'html'
        )
      end

      let(:part) { described_class.new(name: name, value: value, context: context, renderer: renderer) }

      context 'same renderer' do
        it 'renders correctly' do
          new_part = part.new(value: 'new value')
          expect(part._render(:hello)).to eql(new_part._render(:hello))
        end
      end

      context 'new renderer' do
        let(:new_renderer) do
          Dry::View::Renderer.new(
            [Dry::View::Path.new(SPEC_ROOT.join('fixtures/templates_override'))],
            format: 'html'
          )
        end

        it 'renders correctly' do
          new_part = part.new(value: 'new value', renderer: new_renderer)
          expect(part._render(:hello)).to eql('<h1>Partial hello</h1>')
          expect(new_part._render(:hello)).to eql('<h1>Partial new hello</h1>')
        end
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
      let(:value) { double(greeting: 'hello from value') }

      it 'calls a matching method on the value' do
        expect(part.greeting).to eq 'hello from value'
      end

      it 'forwards all arguments to the method' do
        blk = -> { }
        part.greeting 'args', &blk

        expect(value).to have_received(:greeting).with('args', &blk)
      end

      it 'raises an error if no metho matches' do
        expect { part.farewell }.to raise_error(NoMethodError)
      end
    end
  end

  context 'without a renderer' do
    subject(:part) { described_class.new(name: name, value: value, context: context) }

    let(:name) { :user }
    let(:value) { double('value') }
    let(:context) { double('context') }

    describe '#initialize' do
      it 'can be initialized' do
        expect(part).to be_an_instance_of(Dry::View::Part)
      end

      it 'raises an exception when render is called' do
        expect { part.render(:info) }.to raise_error(Dry::View::MissingRendererError).with_message('No renderer provided')
      end
    end
  end
end
