describe PagesController do
  render_views

  let!(:test_page) { FactoryGirl.create :page }
  let!(:test_paged) { FactoryGirl.create :paged }

  describe '#index' do
    before(:each) { get :index }
    it 'sets @pages' do
      expect(assigns(:pages)).to eq [test_page]
    end
    it 'sets session[:came_from] to :page' do
      expect(session[:came_from]).to eq :page
    end
    it 'renders :index template' do
      expect(response).to render_template :index
    end
  end

  describe '#show' do
    before(:each) { get :show, id: test_page.id }
    it 'sets @page' do
      expect(assigns(:page)).to eq test_page
    end
    it 'renders :show template' do
      expect(response).to render_template :show
    end
  end

  describe '#new' do
    before(:each) { get :new }
    it 'sets @page' do
      expect(assigns(:page)).to be_a_new Page
      expect(assigns(:page)).not_to be_persisted
    end
    it 'renders :new template' do
      expect(response).to render_template :new
    end
  end

  describe '#edit' do
    before(:each) { get :edit, id: test_page.id }
    it 'sets @page' do
      expect(assigns(:page)).to eq test_page
    end
    it 'renders :edit template' do
      expect(response).to render_template :edit
    end
  end

  describe '#create' do
    context 'with valid params' do
      let(:post_create) { post :create, page: FactoryGirl.attributes_for(:page) }
      it 'assigns @page' do
        post_create
        expect(assigns(:page)).to be_a Page
        expect(assigns(:page)).to be_persisted
      end
      it 'saves the new object' do
        expect{ post_create }.to change(Page, :count).by(1)
      end
      #FIXME: 2 contexts for paged_id present vs absent, determines redirect_to
      it 'redirects to the object' do
        post_create
        expect(response).to redirect_to assigns(:page)
      end
    end
    context 'with invalid params' do
      before(:each) do
        first_page = FactoryGirl.create :page, paged: test_paged
        test_paged.reload
        post :create, page: FactoryGirl.attributes_for(:page, paged_id: test_paged.id)
      end
      it 'renders the new template' do
        expect(response).to render_template(:new)
      end
    end
  end

  describe '#update' do
    context 'when came from paged' do
      before(:each) { session[:came_from] = :paged }
      context 'with parent paged' do
        before(:each) do
          test_page.paged_id = test_paged.id
          test_page.save
          put :update, id: test_page.id, page: { logical_number: test_page.logical_number + " updated" }
        end
        it 'redirects to parent paged' do
          expect(response).to redirect_to paged_path(test_paged.id)
        end
      end
      context 'without a parent paged' do
        before(:each) do
          put :update, id: test_page.id, page: { logical_number: test_page.logical_number + " updated" }
        end
        it 'redirects to paged_url' do
          puts "paged: #{test_paged.id}, page: #{test_page.id}"
          #FIXME: where is the controller meant to send us?  Surely not to paged_url(@page.id) because that's mixing paged/page...
          expect(response).to redirect_to pageds_path
        end
      end
    end
    context 'with valid params' do
      let!(:original_number) { test_page.logical_number } 
      before(:each) { put :update, id: test_page.id, page: { logical_number: test_page.logical_number + " updated" } }
      it 'assigns @page' do
        expect(assigns(:page)).to eq test_page
      end
      it 'updates values' do
        expect(test_page.logical_number).to eq original_number
        test_page.reload
        expect(test_page.logical_number).not_to eq original_number
      end
      it 'flashes success' do
        expect(flash[:notice]).to match /success/i
      end
      it 'redirects to updated page' do
        expect(response).to redirect_to test_page
      end
    end
    context 'with invalid params' do
      specify 'FIXME: untestable until invalid page parameters determined'
      context 'with invalid params' do
      before(:each) do
        first_page = FactoryGirl.create :page, paged: test_paged
        test_paged.reload
        put :update, id: test_page.id, page: { logical_number: test_page.logical_number + " updated", paged_id: test_paged.id }
      end
      it 'renders the edit template' do
        expect(response).to render_template(:edit)
      end
    end
    end
=begin
    it 'stores a previous-page link' do
      apage = mock_model(Page, :prev_page= => nil, update: nil)
      expect(Page).to receive(:find).and_return(apage)
      expect(apage).to receive(:update).with('prev_page' => 'page:3')
      put :update, {
        page: {prev_page: 'page:3'},
        id: 'page:4'
      }
      assert_response :success
    end

    it 'stores a next-page link' do
      apage = mock_model(Page, :next_page= => nil, update: nil)
      expect(Page).to receive(:find).and_return(apage)
      expect(apage).to receive(:update).with('next_page' => 'page:5')
      put :update, {
        page: {next_page: 'page:5'},
        id: 'page:4'
      }
      assert_response :success
    end

    it 'stores a new image datastream'

    it 'stores a new OCR datastream'

    it 'stores a new XML datastream' do
      xml_upload = fixture_file_upload('/xml-test.xml', 'application/xml')

      apage = mock_model(Page,
                         xml_file: xml_upload,
                         :xml_file= => nil,
                         update: nil)

      expect(Page).to receive(:find).and_return(apage)
      expect(apage).to receive(:update).with('xml_file' => xml_upload)
      put :update, {
        page: {xml_file: xml_upload},
        id: '1'
      }
      assert_response :success
    end
=end
  end

  describe '#destroy' do
    let(:delete_destroy) { delete :destroy, id: test_page.id }
    it 'destroys a Page' do
      expect{ delete_destroy }.to change(Page, :count).by(-1)
    end
    it 'redirects to pages index' do
      delete_destroy
      expect(response).to redirect_to pages_path
    end
  end

end
