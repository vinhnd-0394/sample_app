require "rails_helper"
include SessionsHelper

RSpec.describe UsersController, type: :controller do
  let! (:user) { create(:user) }

  describe "#show" do
    context "when user found" do
      it "render show template" do
        get :show, params: { id: user.id }
        expect(response).to render_template(:show)
      end
    end

    context "when user not found" do
      before { get :show, params: { id: User.first.id - 1  } }

      it "displays a flash danger" do
        expect(flash[:danger]).to eq I18n.t("user.not_found")
      end

      it "redirects to the root path" do
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "#new" do
    context "when user is logged in" do
      before do
        log_in user
        get :new
      end

      it "redirects to the root path" do
        expect(response).to redirect_to(root_path)
      end
    end

    context "when user is not logged in" do
      before { get :new }

      it "return a new User object" do
        expect(assigns(:user)).to be_a_new(User)
      end

      it "render new template" do
        expect(response).to render_template(:new)
      end
    end
  end

  describe "#create" do
    context "when valid params" do
      before do
        post :create, params: {user: attributes_for(:user)}
      end

      it "displays a flash success" do
        expect(flash[:success]).to eq I18n.t("register.success.message")
      end

      it "redirects to the root path" do
        expect(response).to redirect_to(root_path)
      end
    end

    context "when invalid params" do
      before do
        post :create, params: {user: attributes_for(:user, name: "")}
      end

      it "displays a flash danger" do
        expect(flash[:danger]).to eq I18n.t("register.error")
      end

      it "render new template" do
        expect(response).to render_template(:new)
      end
    end
  end
end
