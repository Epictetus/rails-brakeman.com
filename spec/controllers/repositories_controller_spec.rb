require 'spec_helper'

describe RepositoriesController do
  before do
    user = FactoryGirl.create(:user, nickname: "flyerhzm")
    sign_in user
    Repository.any_instance.stubs(:sync_github)
    @repository = FactoryGirl.create(:repository, user: user)
  end

  context "GET :new" do
    it "should assign repository" do
      get :new
      response.should be_ok
      assigns(:repository).should_not be_nil
    end
  end

  context "POST :create" do
    it "should redirect to edit page if create successfully" do
      controller.stubs(:own_repository?).returns(true)
      controller.stubs(:org_repository?).returns(true)
      post :create, repository: {github_name:"flyerhzm/test"}
      repository = assigns(:repository)
      response.should redirect_to([:edit, repository])
    end

    it "should render new page if create failed" do
      controller.stubs(:own_repository?).returns(true)
      controller.stubs(:org_repository?).returns(true)
      Repository.any_instance.stubs(:save).returns(false)
      post :create, repository: {github_name:"flyerhzm/test"}
      response.should render_template(:new)
    end

    it "should redirect ot new if user is not owner" do
      controller.stubs(:own_repository?).returns(false)
      controller.stubs(:org_repository?).returns(false)
      post :create, repository: {github_name:"flyerhzm/test"}
      response.should redirect_to([:new, :repository])
    end
  end

  context "GET :edit" do
    it "should assign repository" do
      get :edit, id: @repository.id
      response.should be_ok
      assigns(:repository).should == @repository
    end
  end

  context "PUT :update" do
    it "should redirecrt to edit page if update successfully" do
      Repository.any_instance.expects(:update_attributes).returns(true)
      put :update, id: @repository.id
      response.should redirect_to([:edit, @repository])
    end

    it "should render edit page if update failed" do
      Repository.any_instance.expects(:update_attributes).returns(false)
      put :update, id: @repository.id
      response.should render_template(:edit)
    end
  end

  context "GET :show" do
    it "shoud assign repository" do
      get :show, id: @repository.id
      response.should be_ok
      assigns(:repository).should_not be_nil
    end

    it "should assign build if repository has build" do
      FactoryGirl.create(:build, repository: @repository)
      get :show, id: @repository.id
      response.should render_template("builds/show")
      assigns(:build).should_not be_nil
    end
  end
end
