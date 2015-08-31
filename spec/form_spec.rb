require 'spec_helper'

describe 'NestedForm' do
  include Capybara::DSL

  def check_form
    page.should have_no_css('form .fields input[id$=name]')
    click_link 'Add new task'
    page.should have_css('form .fields input[id$=name]', :count => 1)
    expect(page).to have_selector('form .fields input[id$=name]')
    expect(page).to have_selector('form .fields input[id$=_destroy]', visible: false)
    expect(find('form .fields input[id$=_destroy]', visible: false).value).to eq 'false'
    click_link 'Remove'
    expect(find('form .fields input[id$=_destroy]', visible: false).value).to eq '1'
    expect(find('form .fields input[id$=name]', visible: false)).to_not be_visible

    click_link 'Add new task'
    click_link 'Add new task'
    fields = all('form .fields', visible: false)
    expect(fields.select { |field| field.visible? }.count).to eq 2
    expect(fields.reject { |field| field.visible? }.count).to eq 1
  end

  it 'should work with jQuery', :js => true do
    Capybara.exact = false
    visit '/projects/new'
    check_form
  end

  it 'should work with Prototype', :js => true do
    Capybara.exact = false
    visit '/projects/new?type=prototype'
    check_form
  end

  it 'works when there are no inputs for intermediate association', :js => true do
    visit '/projects/without_intermediate_inputs'
    click_link 'Add new task'
    click_link 'Add new milestone'
    click_link 'Add new milestone'
    inputs = all('.fields .fields input[id$=name]')
    inputs.first[:name].should_not eq(inputs.last[:name])
  end

  it 'generates correct name for the nested input', :js => true do
    visit '/projects/new?type=jquery'
    click_link 'Add new task'
    click_link 'Add new milestone'
    name = find('.fields .fields input[id$=name]')[:name]
    name.should match(/\Aproject\[tasks_attributes\]\[\d+\]\[milestones_attributes\]\[\d+\]\[name\]\z/)
  end

  it 'generates correct name for the nested input (has_one => has_many)', :js => true do
    visit '/companies/new?type=jquery'
    click_link 'Add new task'
    name = find('.fields .fields input[id$=name]')[:name]
    name.should match(/\Acompany\[project_attributes\]\[tasks_attributes\]\[\d+\]\[name\]\z/)
  end

  it 'generates correct name for the nested input (has_one => has_many => has_many)', :js => true do
    visit '/companies/new?type=jquery'
    click_link 'Add new task'
    click_link 'Add new milestone'
    name = find('.fields .fields .fields input[id$=name]')[:name]
    name.should match(/\Acompany\[project_attributes\]\[tasks_attributes\]\[\d+\]\[milestones_attributes\]\[\d+\]\[name\]\z/)
  end

end
