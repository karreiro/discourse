require 'spec_helper'

describe Admin::BadgesController do

  context "while logged in as an admin" do
    let!(:user) { log_in(:admin) }
    let!(:badge) { Fabricate(:badge) }

    context 'index' do
      it 'returns badge index' do
        xhr :get, :index
        response.should be_success
      end
    end

    context '.save_badge_groupings' do

      it 'can save badge groupings' do
        groupings = BadgeGrouping.all.order(:position).to_a
        groupings << BadgeGrouping.new(name: 'Test 1')
        groupings << BadgeGrouping.new(name: 'Test 2')

        groupings.shuffle!

        names = groupings.map{|g| g.name}
        ids = groupings.map{|g| g.id.to_s}


        xhr :post, :save_badge_groupings, ids: ids, names: names

        groupings2 = BadgeGrouping.all.order(:position).to_a

        groupings2.map{|g| g.name}.should == names
        (groupings.map(&:id) - groupings2.map{|g| g.id}).compact.should be_blank

        ::JSON.parse(response.body)["badge_groupings"].length.should == groupings2.length
      end
    end

    context '.badge_types' do
      it 'returns success' do
        xhr :get, :badge_types
        response.should be_success
      end

      it 'returns JSON' do
        xhr :get, :badge_types
        ::JSON.parse(response.body)["badge_types"].should be_present
      end
    end

    context '.destroy' do
      it 'returns success' do
        xhr :delete, :destroy, id: badge.id
        response.should be_success
      end

      it 'deletes the badge' do
        xhr :delete, :destroy, id: badge.id
        Badge.where(id: badge.id).count.should eq(0)
      end
    end

    context '.update' do
      it 'returns success' do
        xhr :put, :update, id: badge.id, name: "123456", badge_type_id: badge.badge_type_id, allow_title: false, multiple_grant: false, enabled: true
        response.should be_success
      end

      it 'updates the badge' do
        xhr :put, :update, id: badge.id, name: "123456", badge_type_id: badge.badge_type_id, allow_title: false, multiple_grant: true, enabled: true
        badge.reload.name.should eq('123456')
      end
    end
  end
end
