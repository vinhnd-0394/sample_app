require "rails_helper"
include SessionsHelper

RSpec.describe PostsController, type: :controller do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }

  let!(:posts) do
    create_list(:post, 15, user: user, status: :published)
  end

  let!(:other_posts) do
    create_list(:post,5, user: other_user, status: :published)
  end

  let!(:limit) { Settings.limit.limit_10 }

  shared_examples "when user is not owner" do |action, http_method|
    context "when user is not owner" do
      before do
        send(http_method, action, params: { id: posts.first.id })
      end

      it "displays a flash danger" do
        expect(flash[:danger]).to eq I18n.t("post.not_owner")
      end

      it "redirect to root path" do
        expect(response).to redirect_to(root_path)
      end
    end
  end

  shared_examples "when user is not logged in" do |action, http_method, id = nil|
    context "when user is not logged in" do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        id ? send(http_method, action, params: { id: posts.first.id }) : send(http_method, action)
      end

      it "displays flash danger" do
        expect(flash[:danger]).to eq I18n.t("login.not_login.message")
      end

      it "redirect to login template" do
        expect(response).to redirect_to login_path
      end
    end
  end

  shared_examples "when Post not found" do
    it "display flash danger" do
      expect(flash[:danger]).to eq I18n.t("post.not_found")
    end

    it "redirect to root path" do
      expect(response).to redirect_to(root_path)
    end
  end

  describe "#index" do
    before do
      get :index
    end

    it "assigns @posts with the first 10 published posts" do
      expect(assigns(:posts).size.keys.size).to be <= limit
    end

    it "assigns only published posts" do
      assigns(:posts).each do |post|
        expect(post.status).to eq("published")
      end
    end

    it "assigns @posts with posts including associated users" do
      assigns(:posts).each do |post|
        expect(post.user).to be_present
      end
    end

    it "assigns @top_users with the users having the most published posts" do
      expect(assigns(:top_users)).to include(user, other_user)
    end

    it "assigns @top_users with a maximum of limit users" do
      expect(assigns(:top_users).size.keys.size).to be <= limit
    end

    it "render index template" do
      expect(response).to render_template(:index)
    end
  end

  describe "#show" do
    context "when Post not found" do
      before { get :show, params: { id: Post.first.id - 1  } }
      include_examples "when Post not found"
    end

    context "when Post found" do
      before do
        get :show, params: { id: posts.first.id }
      end

      it "assigns the requested post to @post" do
        expect(assigns(:post)).to eq posts.first
      end

      it "render post template" do
        expect(response).to render_template(:show)
      end
    end
  end

  describe "#new" do
    include_examples "when user is not logged in", :new, :get

    context "when user is logged in" do
      before do
        log_in user
        get :new
      end

      it "return a new Post object" do
        expect(assigns(:post)).to be_a_new(Post)
      end

      it "render new template" do
        expect(response).to render_template(:new)
      end
    end
  end

  describe "#create" do
    include_examples "when user is not logged in", :create, :post

    context "when user is logged in" do
      before { log_in user }

      context "with invalid params" do
        before {
          post :create, params: {post: attributes_for(:post, status: "")}
        }

        it "does not create a new post" do
          expect {
            post :create, params: {post: attributes_for(:post, status: "")}
          }.not_to change(Post, :count)
        end

        it "display flash now danger message" do
          expect(flash.now[:danger]).to eq(I18n.t("post.create.failed.message"))
        end

        it "re-render new template" do
          expect(response).to render_template(:new)
        end
      end

      context "with valid params" do
        before { post :create, params: {post: attributes_for(:post)} }

        it "creates a new post" do
          expect {
            post :create, params: {post: attributes_for(:post)}
          }.to change(Post, :count).by(1)
        end

        it "display flash success message" do
          expect(flash[:success]).to eq(I18n.t('post.create.success.message'))
        end

        it "redirect to root path" do
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end

  describe "#edit" do
    include_examples "when user is not logged in", :edit, :get, true

    context "when user is logged in" do
      before do
        allow(controller).to receive(:current_user).and_return(other_user)
      end

      context "when Post not found" do
        before { get :edit, params: { id: Post.first.id - 1  } }
        include_examples "when Post not found"
      end

      context "when Post found" do
        include_examples "when user is not owner", :edit, :get

        context "when user is owner" do
          before do
            allow(controller).to receive(:current_user).and_return(user)
            get :edit, params: { id: posts.first.id }
          end

          it "assigns the requested post to @post" do
            expect(assigns(:post)).to eq posts.first
          end

          it "render edit template" do
            expect(response).to render_template(:edit)
          end
        end
      end
    end
  end

  describe "#update" do
    include_examples "when user is not logged in", :update, :put, true

    context "when user is logged in" do
      before do
        allow(controller).to receive(:current_user).and_return(other_user)
      end

      context "when Post not found" do
        before { put :update, params: { id: Post.first.id - 1  } }
        include_examples "when Post not found"
      end

      context "when Post found" do
        include_examples "when user is not owner", :update, :put

        context "when user is owner" do
          before do
            allow(controller).to receive(:current_user).and_return(user)
          end

          context "with invalid params" do
            before {
              put :update, params: {
                id: posts.first.id,
                post: attributes_for(:post, content: "")
              }
            }

            it "display flash now danger message" do
              expect(flash.now[:danger]).to eq(I18n.t("post.update.failed.message"))
            end

            it "re-render edit template" do
              expect(response).to render_template(:edit)
            end
          end

          context "with valid params" do
            before {
              put :update, params: {
                id: posts.first.id,
                post: { content: "Vinh đẹp trai"}
              }
            }

            it "updated post" do
              posts.first.reload
              expect(posts.first.content).to eq("Vinh đẹp trai")
            end

            it "display flash success message" do
              expect(flash[:success]).to eq(I18n.t("post.update.success.message"))
            end

            it "redirect to root path" do
              expect(response).to redirect_to(post_path)
            end
          end
        end
      end
    end
  end

  describe "#delete" do
    include_examples "when user is not logged in", :destroy, :delete, true

    context "when user is logged in" do
      before do
        allow(controller).to receive(:current_user).and_return(other_user)
      end

      context "when Post not found" do
        before { delete :destroy, params: { id: Post.first.id - 1  } }
        include_examples "when Post not found"
      end

      context "when Post found" do
        include_examples "when user is not owner", :destroy, :delete

        context "when user is owner" do
          before do
            allow(controller).to receive(:current_user).and_return(user)
            delete :destroy, params: { id: posts.first.id }
          end

          context "when delete failed" do
            before do
              allow_any_instance_of(Post).to receive(:destroy).and_return(false)
            end

            it "display flash danger message" do
              delete :destroy, params: { id: Post.first.id }
              expect(flash[:danger]).to eq I18n.t("post.delete.failed.message")
            end

            it "redirect to root path" do
              expect(response).to redirect_to(root_path)
            end
          end

          context "when delete success" do
            it "deletes the post" do
              expect {
                delete :destroy, params: { id: posts.first.id }
              }.not_to change(Post, :count)
            end

            it "redirect to root path" do
              expect(response).to redirect_to(root_path)
            end
          end
        end
      end
    end
  end
end
