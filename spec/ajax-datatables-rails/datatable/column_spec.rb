require 'spec_helper'

describe AjaxDatatablesRails::Datatable::Column do

  let(:view) { double('view', params: sample_params) }
  let(:datatable) { ComplexDatatable.new(view) }

  describe 'username column' do

    let(:column) { datatable.datatable.columns.first }

    before do
      datatable.params[:columns] = {'0'=>{'data'=>'username', 'name'=>'', 'searchable'=>'true', 'orderable'=>'true', 'search'=>{'value'=>'searchvalue', 'regex'=>'false'}}}
    end

    it 'should be orderable' do
      expect(column.orderable?).to eq(true)
    end

    it 'should be searchable' do
      expect(column.searchable?).to eq(true)
    end

    it 'should be searched' do
      expect(column.searched?).to eq(true)
    end

    it 'should have connected to id column' do
      expect(column.data).to eq('username')
    end

    describe '#search' do
      it 'child class' do
        expect(column.search).to be_a(AjaxDatatablesRails::Datatable::SimpleSearch)
      end

      it 'should have search value' do
        expect(column.search.value).to eq('searchvalue')
      end

      it 'should not regex' do
        expect(column.search.regexp?).to eq false
      end
    end

    describe '#cond' do
      it 'should be :like by default' do
        expect(column.cond).to eq(:like)
      end
    end

    describe '#source' do
      it 'should be :like by default' do
        expect(column.source).to eq('User.username')
      end
    end

    describe '#search_query' do
      it 'should buld search query' do
        expect(column.search_query.to_sql).to include('%searchvalue%')
      end
    end

    describe '#sort_query' do
      it 'should build sort query' do
        expect(column.sort_query).to eq('users.username')
      end
    end

    describe '#use_regex?' do
      it 'should be true by default' do
        expect(column.use_regex?).to be true
      end
    end

    describe '#delimiter' do
      it 'should be - by default' do
        expect(column.delimiter).to eq('-')
      end
    end
  end

  describe 'last_name column' do
    let(:column) { datatable.datatable.columns.last }

    before do
      datatable.params[:columns] = {'0'=>{'data'=>'last_name', 'name'=>'', 'searchable'=>'true', 'orderable'=>'true', 'search'=>{'value'=>'', 'regex'=>'false'}}}
    end

    it 'should be orderable' do
      expect(column.orderable?).to eq(true)
    end

    it 'should be searchable' do
      expect(column.searchable?).to eq(true)
    end

    it 'should have connected to id column' do
      expect(column.data).to eq('last_name')
    end

    describe '#formater' do
      it 'should be a proc' do
        expect(column.formater).to be_a(Proc)
      end
    end
  end

end
