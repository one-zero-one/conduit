describe Tillless::Conduit::TC::GetProductsCommand do
  extend WebStub::SpecHelpers

  it "should exist" do
    should.not.raise(NameError) { Tillless::Conduit::TC::GetProductsCommand }
  end

  URL_FOR_GET_PRODUCTS  = 'http://api.tillless.com/api/products?page=1&per_page=1'
  JSON_FOR_GET_PRODUCTS = BW::JSON.parse <<EOF
{
 "count": 1,
 "total_count": 16,
 "current_page": 1,
 "per_page": "1",
 "pages": 16,
 "products": [
  {
   "id": 1,
   "name": "Ruby on Rails Tote",
   "description": "Sequi voluptas sed libero error odit ut dolores. Ut ipsum ipsam sed aut fuga. Quo deserunt quia accusantium ipsum omnis quo eligendi. Quaerat magnam minima quia maiores. Et asperiores temporibus aut est illo.",
   "price": "15.99",
   "display_price": "$15.99",
   "available_on": "2015-01-27T08:44:46.551Z",
   "slug": "ruby-on-rails-tote",
   "meta_description": null,
   "meta_keywords": null,
   "shipping_category_id": 1,
   "taxon_ids": [
    15,
    7
   ],
   "total_on_hand": 10,
   "has_variants": false,
   "master": {
    "id": 1,
    "name": "Ruby on Rails Tote",
    "sku": "ROR-00011",
    "price": "15.99",
    "weight": "0.0",
    "height": null,
    "width": null,
    "depth": null,
    "is_master": true,
    "slug": "ruby-on-rails-tote",
    "description": "Sequi voluptas sed libero error odit ut dolores. Ut ipsum ipsam sed aut fuga. Quo deserunt quia accusantium ipsum omnis quo eligendi. Quaerat magnam minima quia maiores. Et asperiores temporibus aut est illo.",
    "track_inventory": true,
    "cost_price": "17.0",
    "display_price": "$15.99",
    "options_text": "",
    "in_stock": true,
    "is_backorderable": true,
    "total_on_hand": 10,
    "is_destroyed": false,
    "option_values": [],
    "images": [
     {
      "id": 21,
      "position": 1,
      "attachment_content_type": "image/jpeg",
      "attachment_file_name": "ror_tote.jpeg",
      "type": "Spree::Image",
      "attachment_updated_at": "2015-01-27T08:45:04.146Z",
      "attachment_width": 360,
      "attachment_height": 360,
      "alt": null,
      "viewable_type": "Spree::Variant",
      "viewable_id": 1,
      "mini_url": "/spree/products/21/mini/ror_tote.jpeg?1422348304",
      "small_url": "/spree/products/21/small/ror_tote.jpeg?1422348304",
      "product_url": "/spree/products/21/product/ror_tote.jpeg?1422348304",
      "large_url": "/spree/products/21/large/ror_tote.jpeg?1422348304"
     },
     {
      "id": 22,
      "position": 2,
      "attachment_content_type": "image/jpeg",
      "attachment_file_name": "ror_tote_back.jpeg",
      "type": "Spree::Image",
      "attachment_updated_at": "2015-01-27T08:45:04.808Z",
      "attachment_width": 360,
      "attachment_height": 360,
      "alt": null,
      "viewable_type": "Spree::Variant",
      "viewable_id": 1,
      "mini_url": "/spree/products/22/mini/ror_tote_back.jpeg?1422348304",
      "small_url": "/spree/products/22/small/ror_tote_back.jpeg?1422348304",
      "product_url": "/spree/products/22/product/ror_tote_back.jpeg?1422348304",
      "large_url": "/spree/products/22/large/ror_tote_back.jpeg?1422348304"
     }
    ]
   },
   "variants": [],
   "option_types": [],
   "product_properties": [
    {
     "id": 25,
     "product_id": 1,
     "property_id": 9,
     "value": "Tote",
     "property_name": "Type"
    },
    {
     "id": 26,
     "product_id": 1,
     "property_id": 10,
     "value": "15'' x 18'' x 6''",
     "property_name": "Size"
    },
    {
     "id": 27,
     "product_id": 1,
     "property_id": 11,
     "value": "Canvas",
     "property_name": "Material"
    }
   ],
   "classifications": [
    {
     "taxon_id": 7,
     "position": 1,
     "taxon": {
      "id": 7,
      "name": "Bags",
      "pretty_name": "Categories -> Bags",
      "permalink": "categories/bags",
      "parent_id": 5,
      "taxonomy_id": 2,
      "taxons": []
     }
    },
    {
     "taxon_id": 15,
     "position": 1,
     "taxon": {
      "id": 15,
      "name": "Rails",
      "pretty_name": "Brand -> Rails",
      "permalink": "brand/rails",
      "parent_id": 6,
      "taxonomy_id": 3,
      "taxons": []
     }
    }
   ]
  }
 ]
}
EOF

  # Run once at the beginning to set up CDQ and Restikle before all tests
  describe "#{Tillless::Conduit::TC::GetProductsCommand} CDQ and ResourceManager setup" do
    it "should setup #{Restikle::ResourceManager}" do
      Tillless::Conduit::Spec.setup_cdq_and_resource_manager.should == true
    end
  end

  # Command specs (separated from CDQ setup / reset)
  describe "#{Tillless::Conduit::TC::GetProductsCommand} specs" do

    before do
      setup_rest_web_stubs
    end

    after do
      teardown_rest_web_stubs
    end

    def setup_rest_web_stubs
      stub_request(
        :get, URL_FOR_GET_PRODUCTS).
        to_return(json: JSON_FOR_GET_PRODUCTS)
    end

    def teardown_rest_web_stubs
      reset_stubs
    end

    it "#{Tillless::Conduit::TC::GetProductsCommand}.run" do
      @status = :unknown
      @cmd    = Tillless::Conduit::TC::GetProductsCommand.new.run(
        per_page: 1,
        on_success: ->(paginator, objects, page) {
puts ' '
puts 'objects:'
objects.each do |obj|
  puts obj.inspect
end
puts ' '
          cdq.save
          @status = :paging
        },
        on_last_page: ->(paginator) {
          cdq.save
          @status = :success
          resume
        },
        on_failure: ->(paginator, error) {
          @status = :failed
          resume
        }
      )

      wait_max 20.0 do
        @status.should != :failed
        @status.should != :paging
        @status.should != :unknown
        @status.should == :success
      end
    end

  end
end
