require 'rails_helper'
describe TokenPagination::ActiveRecordRelationExtention do
  before(:all) do
    @user = User.create!( name: "user1")
    @user2 = User.create!( name: "user1")
    
    10.times do |index|
      id = index + 1
      @user.books.create(id: id )
    end

    10.times do |index|
      id = index + 11
      @user2.books.create(id: id, rating: id % 4 == 0 ? 1 : 0)
    end
  end

  context "When ordered by id asc" do
    describe "Collection" do
      it_behaves_like "paginated resource" do
        let(:relation) { @user.books.order(id: :asc) }
        let(:expected_ids) { (1 .. 10).to_a }
      end
    end
  end

  context "When ordered by id desc" do
    describe "Collection" do
      it_behaves_like "paginated resource" do
        let(:relation) { @user.books.order(id: :desc) }
        let(:expected_ids) { (1 .. 10).to_a.reverse }
      end
    end
  end

  context "When ordered by multiple columns" do
    describe "Collection" do
      it_behaves_like "paginated resource" do
        let(:relation) { @user2.books.order(rating: :desc).order(id: :desc) }
        let(:expected_ids) { [20, 16, 12, 19, 18, 17, 15, 14, 13, 11] }
      end
    end
  end




end
