RSpec.shared_examples "paginated resource" do
  
  describe "test condition" do
    it "Should be array" do
      expect(expected_ids).to be_instance_of(Array)
    end

    it "length is equal to 10" do
      expect(expected_ids.size).to eq(10)
    end

    it "Should relation" do
      expect(expected_ids).to be_present
    end
  end
    
  let(:result) {
    result = nil
    page.times do
      result = relation.page_by_token(4, result.try(:next_page_token))
    end
    result
  }
          
  describe "First page" do
    let(:page) { 1 }
    it "Should match first 0 .. 3" do
      expect(result.map{|item| item.id } ).to eq(expected_ids[0 .. 3 ])
    end
    it "Should have page_token" do
      expect(result.next_page_token).to be_present
    end
  end
  
  describe "Second page" do
    let(:page) { 2 }
    it "Should match first 4 .. 7" do
      expect(result.map{|item| item.id } ).to eq(expected_ids[4 .. 7])
    end

    it "Should have page_token" do
      expect(result.next_page_token).to be_present
    end
  end

  describe "Third page" do
    let(:page) { 3 }
    it "Should match first 8 .. 9" do
      expect(result.map{|item| item.id } ).to eq(expected_ids[8 .. 9])
    end

    it "Should not have page_token" do
      expect(result.next_page_token).to be_nil
    end
  end
end
