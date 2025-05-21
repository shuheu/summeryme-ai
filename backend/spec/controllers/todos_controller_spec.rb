require 'rails_helper'

RSpec.describe TodosController, type: :controller do
  let!(:todo) { Todo.create(title: 'テストタスク', description: '説明文') }

  describe 'GET #index' do
    it 'タスク一覧を取得できること' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).first['title']).to eq('テストタスク')
    end
  end

  describe 'GET #show' do
    it 'タスク詳細を取得できること' do
      get :show, params: { id: todo.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['title']).to eq('テストタスク')
    end
  end

  describe 'POST #create' do
    it '新規タスクを作成できること' do
      expect {
        post :create, params: { todo: { title: '新しいタスク', description: '新しい説明' } }
      }.to change(Todo, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it 'タイトルがない場合は作成できないこと' do
      post :create, params: { todo: { title: '', description: '説明' } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH #update' do
    it 'タスクを更新できること' do
      patch :update, params: { id: todo.id, todo: { title: '更新タイトル' } }
      expect(response).to have_http_status(:ok)
      expect(todo.reload.title).to eq('更新タイトル')
    end
  end

  describe 'DELETE #destroy' do
    it 'タスクを削除できること' do
      expect {
        delete :destroy, params: { id: todo.id }
      }.to change(Todo, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end