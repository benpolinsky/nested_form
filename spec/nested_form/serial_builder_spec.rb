require "spec_helper"

[NestedForm::Builder].compact.each do |builder|
  describe builder do
    let(:task) do
      Task.new
    end

    let(:template) do
      template = ActionView::Base.new
      template.output_buffer = ""
      template
    end
    
    context "with json" do
      subject do
        builder.new(:item, task, template, {})
      end

      describe '#link_to_add' do
        it "behaves similar to a Rails link_to" do
          expect(subject.link_to_add("Add", :notes)).to eq '<a class="add_nested_fields" data-association="notes" data-blueprint-id="notes_fields_blueprint" href="javascript:void(0)">Add</a>'
          expect(subject.link_to_add("Add", :notes, :class => "foo", :href => "url")).to eq '<a class="foo add_nested_fields" data-association="notes" data-blueprint-id="notes_fields_blueprint" href="url">Add</a>'
          expect(subject.link_to_add(:notes) { "Add" }).to eq '<a class="add_nested_fields" data-association="notes" data-blueprint-id="notes_fields_blueprint" href="javascript:void(0)">Add</a>'
        end

        it 'raises ArgumentError when missing association is provided' do
          expect {
            subject.link_to_add('Add', :bugs)
          }.to raise_error(ArgumentError)
        end

        it 'raises ArgumentError when accepts_nested_attributes_for is missing' do
          expect {
            subject.link_to_add('Add', :not_nested_tasks)
          }.to raise_error(ArgumentError)
        end
      end

      describe '#link_to_remove' do
        it "behaves similar to a Rails link_to" do
          expect(subject.link_to_remove("Remove")).to eq '<input type="hidden" value="false" name="item[_destroy]" id="item__destroy" /><a class="remove_nested_fields" href="javascript:void(0)">Remove</a>'
          expect(subject.link_to_remove("Remove", :class => "foo", :href => "url")).to eq '<input type="hidden" value="false" name="item[_destroy]" id="item__destroy" /><a class="foo remove_nested_fields" href="url">Remove</a>'
          expect(subject.link_to_remove { "Remove" }).to eq '<input type="hidden" value="false" name="item[_destroy]" id="item__destroy" /><a class="remove_nested_fields" href="javascript:void(0)">Remove</a>'
        end

        it 'has data-association attribute' do
          Capybara.exact = false
          #project.tasks.build
          response = subject.fields_for(:notes, :builder => builder) do |tf|
            tf.link_to_remove 'Remove'
          end
          expect(response).to match("a[data-association='notes']")
        end

        context 'when there is more than one nested level' do
          it 'properly detects association name' do
            Capybara.exact = false
            response = subject.fields_for(:notes, :builder => builder) do |tf|
              tf.fields_for(:anything, :builder => builder) do |mf|
                mf.link_to_remove 'Remove'
              end
            end
            expect(response).to match 'a[data-association="anything"]'
          end
        end
      end

      describe '#fields_for', focus: true do
        it "wraps nested fields each in a div with class" do
          fields = if subject.is_a?(NestedForm::SimpleBuilder)
            subject.simple_fields_for(:notes) { "Note" }
          else
            subject.fields_for(:notes) { "Note" }
          end

          fields.should == '<div class="fields">Note</div><div class="fields">Note</div>'
        end
      end

      it "wraps nested fields marked for destruction with an additional class" do
        task = project.tasks.build
        task.mark_for_destruction
        fields = subject.fields_for(:tasks) { 'Task' }
        fields.should eq('<div class="fields marked_for_destruction">Task</div>')
      end

      it "puts blueprint into data-blueprint attribute" do
        task = project.tasks.build
        task.mark_for_destruction
        subject.fields_for(:tasks) { 'Task' }
        subject.link_to_add('Add', :tasks)
        output   = template.send(:after_nested_form_callbacks)
        expected = ERB::Util.html_escape '<div class="fields">Task</div>'
        output.should match(/div.+data-blueprint="#{expected}"/)
      end

      it "adds parent association name to the blueprint div id" do
        task = project.tasks.build
        task.milestones.build
        subject.fields_for(:tasks, :builder => builder) do |tf|
          tf.fields_for(:milestones, :builder => builder) { 'Milestone' }
          tf.link_to_add('Add', :milestones)
        end
        output = template.send(:after_nested_form_callbacks)
        output.should match(/div.+id="tasks_milestones_fields_blueprint"/)
      end

      it "doesn't render wrapper div" do
        task = project.tasks.build
        fields = subject.fields_for(:tasks, :wrapper => false) { 'Task' }

        fields.should eq('Task')

        subject.link_to_add 'Add', :tasks
        output = template.send(:after_nested_form_callbacks)

        output.should match(/div.+data-blueprint="Task"/)
      end

      it "doesn't render wrapper div when collection is passed" do
        task = project.tasks.build
        fields = subject.fields_for(:tasks, project.tasks, :wrapper => false) { 'Task' }

        fields.should eq('Task')

        subject.link_to_add 'Add', :tasks
        output = template.send(:after_nested_form_callbacks)

        output.should match(/div.+data-blueprint="Task"/)
      end

      it "doesn't render wrapper with nested_wrapper option" do
        task = project.tasks.build
        fields = subject.fields_for(:tasks, :nested_wrapper => false) { 'Task' }

        fields.should eq('Task')

        subject.link_to_add 'Add', :tasks
        output = template.send(:after_nested_form_callbacks)

        output.should match(/div.+data-blueprint="Task"/)
      end
    end

    context "with options" do
      subject { builder.new(:item, project, template, {}) }

      context "when model_object given" do
        it "should use it instead of new generated" do
          subject.fields_for(:tasks) {|f| f.object.name }
          subject.link_to_add("Add", :tasks, :model_object => Task.new(:name => 'for check'))
          output   = template.send(:after_nested_form_callbacks)
          expected = ERB::Util.html_escape '<div class="fields">for check</div>'
          output.should match(/div.+data-blueprint="#{expected}"/)
        end
      end
    end
  end
end
