require 'spec_helper'

describe AjaxDatatablesRails::Base do

  let(:params) do
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
  let(:view) { double('view', :params => params) }

  describe 'an instance' do
    it 'requires a view_context' do
      expect { AjaxDatatablesRails::Base.new }.to raise_error
    end

    it 'accepts an options hash' do
      datatable = AjaxDatatablesRails::Base.new(view, :foo => 'bar')
      expect(datatable.options).to eq(:foo => 'bar')
    end
  end

  describe 'helper methods' do
    describe '#offset' do
      it 'defaults to 0' do
        default_view = double('view', :params => {})
        datatable = AjaxDatatablesRails::Base.new(default_view)
        expect(datatable.send(:offset)).to eq(0)
      end

      it 'matches the value on view params[:start] minus 1' do
        paginated_view = double('view', :params => { :start => '11' })
        datatable = AjaxDatatablesRails::Base.new(paginated_view)
        expect(datatable.send(:offset)).to eq(10)
      end
    end

    describe '#page' do
      it 'calculates page number from params[:start] and #per_page' do
        paginated_view = double('view', :params => { :start => '11' })
        datatable = AjaxDatatablesRails::Base.new(paginated_view)
        expect(datatable.send(:page)).to eq(2)
      end
    end

    describe '#per_page' do
      it 'defaults to 10' do
        datatable = AjaxDatatablesRails::Base.new(view)
        expect(datatable.send(:per_page)).to eq(10)
      end

      it 'matches the value on view params[:length]' do
        other_view = double('view', :params => { :length => 20 })
        datatable = AjaxDatatablesRails::Base.new(other_view)
        expect(datatable.send(:per_page)).to eq(20)
      end
    end

    describe '#sort_column' do
      it 'returns a column name from the #sorting_columns array' do
        sort_view = double(
          'view', :params => params
        )
        datatable = AjaxDatatablesRails::Base.new(sort_view)
        allow(datatable).to receive(:sortable_displayed_columns) { ["0", "1"] }
        allow(datatable).to receive(:sortable_columns) { ['User.foo', 'User.bar', 'User.baz'] }

        column = datatable.send(:sort_column, sort_view.params[:order]["0"])
        expectedColunm = AjaxDatatablesRails::StandardColumn.new(User, 'bar', :pg)
        expect(column).to eq(expectedColunm)
      end
    end

    describe '#sort_direction' do
      it 'matches value of params[:sSortDir_0]' do
        sorting_view = double(
          'view',
          :params => {
            :order => {
              '0' => { :column => '1', :dir => 'desc' }
            }
          }
        )
        datatable = AjaxDatatablesRails::Base.new(sorting_view)
        expect(datatable.send(:sort_direction, sorting_view.params[:order]["0"])).to eq(:desc)
      end

      it 'can only be one option from ASC or DESC' do
        sorting_view = double(
          'view',
          :params => {
            :order => {
              '0' => { :column => '1', :dir => 'foo' }
            }
          }
        )
        datatable = AjaxDatatablesRails::Base.new(sorting_view)
        expect(datatable.send(:sort_direction, sorting_view.params[:order]["0"])).to eq(:asc)
      end
    end

    describe '#sortable_columns' do
      it 'returns an array representing database columns' do
        datatable = AjaxDatatablesRails::Base.new(view)
        expect(datatable.sortable_columns).to eq([])
      end
    end

    describe '#searchable_columns' do
      it 'returns an array representing database columns' do
        datatable = AjaxDatatablesRails::Base.new(view)
        expect(datatable.searchable_columns).to eq([])
      end
    end
  end

  describe 'perform' do
    let(:results) { double('Collection', :offset => [], :limit => []) }
    let(:view) { double('view', :params => params) }
    let(:datatable) { AjaxDatatablesRails::Base.new(view) }
    let(:records) { double('Array').as_null_object }

    before(:each) do
      allow(datatable).to receive(:sortable_columns) { ['User.foo', 'User.bar'] }
      allow(datatable).to receive(:sortable_displayed_columns) { ["0", "1"] }
    end

    describe '#paginate_records' do
      it 'defaults to Extensions::SimplePaginator#paginate_records' do
        allow(records).to receive_message_chain(:offset, :limit)

        expect { datatable.send(:paginate_records, records) }.not_to raise_error
      end
    end

    describe '#sort_records' do
      it 'calls #order on a collection' do
        expect(results).to receive(:order)
        datatable.send(:sort_records, results)
      end
    end

    describe '#filter_records' do
      let(:records) {  double('User', :where => []) }

      it 'applies search like functionality on a collection' do
        params[:search][:value] = 'term'
        search_view = double('view', :params => params)

        datatable = AjaxDatatablesRails::Base.new(search_view)
        allow(datatable).to receive(:searchable_columns) { %w{User.foo User.bar} }

        expect(records).to receive(:where)
        datatable.send(:filter_records, records)
      end

      it 'applies search like functionality to an enum field' do
        params[:search][:value] = 'active'
        search_view = double('view', :params => params)

        datatable = AjaxDatatablesRails::Base.new(search_view)
        allow(datatable).to receive(:searchable_columns) { %w{User.status} }

        expect(records).to receive(:where).with(User.arel_table[:status].in([1]))
        datatable.send(:filter_records, records)
      end
    end

    describe '#filter_records with multi word model' do
      let(:records) { double('User', :where => []) }
      let(:search_view) do
        params[:columns]['0'][:search][:value] = 'term1'
        params[:columns]['1'][:search][:value] = 'term2'
        double('view', :params => params)
      end

      it 'applies search like functionality on a collection' do
        datatable = AjaxDatatablesRails::Base.new(search_view)
        allow(datatable).to receive(:searchable_columns) { %w{User.foo User.bar} }

        expect(records).to receive(:where)
        datatable.send(:filter_records, records)
      end
    end
  end

  describe 'hook methods' do
    let(:datatable) { AjaxDatatablesRails::Base.new(view) }

    describe '#data' do
      it 'raises a MethodNotImplementedError' do
        expect { datatable.data }.to raise_error(
          AjaxDatatablesRails::Base::MethodNotImplementedError,
          'Please implement this method in your class.'
        )
      end
    end

    describe '#get_raw_records' do
      it 'raises a MethodNotImplementedError' do
        expect { datatable.get_raw_records }.to raise_error(
          AjaxDatatablesRails::Base::MethodNotImplementedError,
          'Please implement this method in your class.'
        )
      end
    end
  end
end

describe AjaxDatatablesRails::Column do
  describe '#from_string' do
    context "when model class name is regular" do
      it "should successfully get right model class" do
        expect(AjaxDatatablesRails::StandardColumn).to receive(:new).with(User, 'bar', :pg)
        AjaxDatatablesRails::Column.from_string('User.bar', :pg)
      end
    end

    context "when custom named model class" do
      it "should successfully get right model class" do
        expect(AjaxDatatablesRails::StandardColumn).to receive(:new).with(Statistics::Request, 'bar', :pg)
        AjaxDatatablesRails::Column.from_string('Statistics::Request.bar', :pg)
      end
    end


    context "when model class name camelcased" do
      it "should successfully get right model class" do
        expect(AjaxDatatablesRails::StandardColumn).to receive(:new).with(PurchasedOrder, 'bar', :pg)
        AjaxDatatablesRails::Column.from_string('PurchasedOrder.bar', :pg)
      end
    end

    context "when model class name is namespaced" do
      it "should successfully get right model class" do
        expect(AjaxDatatablesRails::StandardColumn).to receive(:new).with(Statistics::Session, 'bar', :pg)
        AjaxDatatablesRails::Column.from_string('Statistics::Session.bar', :pg)
      end
    end

    context "when model class defined but not found" do
      it "raise 'uninitialized constant'" do
        expect {
          AjaxDatatablesRails::Column.from_string('UnexistentModel.bar', :pg)
        }.to raise_error(NameError, /uninitialized constant/)
      end
    end

    context "when the column is an enum" do
      it "should successfully create an enum column" do
        expect(AjaxDatatablesRails::EnumColumn).to receive(:new).with(User, 'status', :pg)
        AjaxDatatablesRails::Column.from_string('User.status', :pg)
      end
    end

    context 'when using deprecated notation' do
      it "should successfully get right model class if exists" do
        expect(AjaxDatatablesRails::StandardColumn).to receive(:new).with(User, 'bar', :pg)
        AjaxDatatablesRails::Column.from_string('users.bar', :pg)
      end

      it "should display a deprecated message" do
        expect(AjaxDatatablesRails::Base).to receive(:deprecated)
        AjaxDatatablesRails::Column.from_string('users.bar', :pg)
      end
    end
  end

  describe "#filter_condition" do
    def filter_typecast(db_type)
      column = AjaxDatatablesRails::StandardColumn.new(User, 'bar', db_type)
      column.filter_condition('value').left.expressions.first.right.to_s
    end

    it "sets VARCHAR if :db_adapter is :pg" do
      expect(filter_typecast(:pg)).to eq('VARCHAR')
    end

    it "sets CHAR if :db_adapter is :mysql2" do
      expect(filter_typecast(:mysql2)).to eq('CHAR')
    end

    it "sets TEXT if :db_adapter is :sqlite3" do
      expect(filter_typecast(:sqlite3)).to eq('TEXT')
    end
  end

  describe "#order_condition" do
    context "for a EnumColumn" do
      it "should return a SQL sort statement" do
        column = AjaxDatatablesRails::EnumColumn.new(User, 'status', :pg)
        expected_asc_sql = 'CASE WHEN "users"."status" = 1 THEN 0 WHEN "users"."status" = 0 THEN 1 ELSE "users"."status" END ASC'
        expect(column.order_condition(:asc)).to eq(Arel::Nodes::SqlLiteral.new(expected_asc_sql))

        expected_desc_sql = 'CASE WHEN "users"."status" = 1 THEN 0 WHEN "users"."status" = 0 THEN 1 ELSE "users"."status" END DESC'
        expect(column.order_condition(:desc)).to eq(Arel::Nodes::SqlLiteral.new(expected_desc_sql))
      end
    end
  end
end

describe AjaxDatatablesRails::Configuration do
  let(:config) { AjaxDatatablesRails::Configuration.new }

  describe "default config" do
    it "default db_adapter should :pg (postgresql)" do
      expect(config.db_adapter).to eq(:pg)
    end
  end

  describe "custom config" do
    it 'should accept db_adapter custom value' do
      config.db_adapter = :mysql2
      expect(config.db_adapter).to eq(:mysql2)
    end
  end
end

describe AjaxDatatablesRails do
  describe "configurations" do
    context "configurable from outside" do
      before(:each) do
        AjaxDatatablesRails.configure do |config|
          config.db_adapter = :mysql2
        end
      end

      it "should have custom value" do
        expect(AjaxDatatablesRails.config.db_adapter).to eq(:mysql2)
      end
    end
  end
end
