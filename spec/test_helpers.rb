def sample_params
  {
    :draw => '5',
    :columns => {
      "0" => {
        :data => '0',
        :name => '',
        :searchable => true,
        :orderable => true,
        :search => { :value => '', :regex => false }
      },
      "1" => {
        :data => '1',
        :name => '',
        :searchable => true,
        :orderable => true,
        :search => { :value => '', :regex => false }
      }
    },
    :order => { "0" => { :column => '1', :dir => 'desc' } },
    :start => '0',
    :length => '10',
    :search => { :value => '', :regex => false },
    '_' => '1403141483098'
  }
end

class SampleDatatable < AjaxDatatablesRails::Base
  def view_columns
    @view_columns ||= []
  end

  def data
    [{}, {}]
  end

  def get_raw_records
  end
end
