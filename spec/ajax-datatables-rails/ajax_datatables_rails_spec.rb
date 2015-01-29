require 'spec_helper'

describe AjaxDatatablesRails::Base do

  params = {
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

        expect(datatable.send(:sort_column, sort_view.params[:order]["0"])).to eq('users.bar')
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
        expect(datatable.send(:sort_direction, sorting_view.params[:order]["0"])).to eq('DESC')
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
        expect(datatable.send(:sort_direction, sorting_view.params[:order]["0"])).to eq('ASC')
      end
    end

    describe "#configure" do
      let(:datatable) do
        class FooDatatable < AjaxDatatablesRails::Base
        end

        FooDatatable.new view
      end

      context "when model class name is regular" do
        it "should successfully get right model class" do
          expect(
            datatable.send(:search_condition, 'User.bar', 'bar')
          ).to be_a(Arel::Nodes::Matches)
        end
      end

      context "when custom named model class" do
        it "should successfully get right model class" do
          expect(
            datatable.send(:search_condition, 'Statistics::Request.bar', 'bar')
          ).to be_a(Arel::Nodes::Matches)
        end
      end


      context "when model class name camelcased" do
        it "should successfully get right model class" do
          expect(
            datatable.send(:search_condition, 'PurchasedOrder.bar', 'bar')
          ).to be_a(Arel::Nodes::Matches)
        end
      end

      context "when model class name is namespaced" do
        it "should successfully get right model class" do
          expect(
            datatable.send(:search_condition, 'Statistics::Session.bar', 'bar')
          ).to be_a(Arel::Nodes::Matches)
        end
      end

      context "when model class defined but not found" do
        it "raise 'uninitialized constant'" do
          expect {
            datatable.send(:search_condition, 'UnexistentModel.bar', 'bar')
          }.to raise_error(NameError, /uninitialized constant/)
        end
      end

      context 'when using deprecated notation' do
        it 'should successfully get right model class if exists' do
          expect(
            datatable.send(:search_condition, 'users.bar', 'bar')
          ).to be_a(Arel::Nodes::Matches)
        end

        it 'should display a deprecated message' do
          expect(AjaxDatatablesRails::Base).to receive(:deprecated)
          datatable.send(:search_condition, 'users.bar', 'bar')
        end
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
      let(:search_view) { double('view', :params => params) }

      it 'applies search like functionality on a collection' do
        datatable = AjaxDatatablesRails::Base.new(search_view)
        allow(datatable).to receive(:searchable_columns) { ['users.foo'] }

        expect(records).to receive(:where)
        records.where
        datatable.send(:filter_records, records)
      end
    end

    describe '#filter_records with multi word model' do
      let(:records) { double('UserData', :where => []) }
      let(:search_view) { double('view', :params => params) }

      it 'applies search like functionality on a collection' do
        datatable = AjaxDatatablesRails::Base.new(search_view)
        allow(datatable).to receive(:searchable_columns) { ['user_datas.bar'] }

        expect(records).to receive(:where)
        records.where
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

  describe '#typecast' do
    params = {
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
    let(:view) { double('view', :params => params) }
    let(:datatable) { AjaxDatatablesRails::Base.new(view) }

    it 'returns VARCHAR if :db_adapter is :pg' do
      expect(datatable.send(:typecast)).to eq('VARCHAR')
    end

    it 'returns CHAR if :db_adapter is :mysql2' do
      allow_any_instance_of(AjaxDatatablesRails::Configuration).to receive(:db_adapter) { :mysql2 }
      expect(datatable.send(:typecast)).to eq('CHAR')
    end

    it 'returns TEXT if :db_adapter is :sqlite3' do
      allow_any_instance_of(AjaxDatatablesRails::Configuration).to receive(:db_adapter) { :sqlite3 }
      expect(datatable.send(:typecast)).to eq('TEXT')
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
