# frozen_string_literal: true

Rails.application.routes.draw do

  scope "(:locale)", locale: /en|es/ do
    root to: 'home#index'
    devise_for :users, controllers: { sessions: 'users/sessions' }
    namespace :admin do
      root to: 'home#index'
      resources :delayed_jobs, only: [:index, :destroy, :new] do
        member do
          put :run_job
        end
        put :test_email, on: :collection
      end
      resources :users do
        member do
          put :impersonate
          put :unlock
          put :pick_release
          put :copy_permit
        end
      end
      resources :clients, except: [:show] do
          member do
        put :reset_batches
        end
        resources :client_locations, except: [:show]
      end
      resources :page_requests, only: [:index] do
        get 'method_hits', on: :collection
        get 'db_runtimes', on: :collection
      end
      resources :log_requests, only: [:index] do
        get 'routing_failures', on: :collection
      end

      resources :permits, except: [:show]
      resources :binpick_batches, only: [:index, :edit, :update] do
      end
    end
    match '/filter' => 'filter#clear', via: :get
    match '/filter' => 'filter#update', via: :put
    match '/filter' => 'filter#sorter', via: :delete
    match '/picker' => 'picker#update', via: :put
    match '/picks' => 'picks#update', via: :put

    resources :receipt_batches do
      get :find_item
      resources :receipt_items, except: [:show] do
        put :found_item
        put :mute
        put :print_label
        get :edit_label
        get :putaway_label
        put :select_default
      end
      put :start_putaway
      get :putaway
      put :close
      put :mute_all
      put :unmute_all
      get :download_861
      put :from_upload, on: :collection
    end
    resources :receipt_locations, except: [:show] do
    end
    resources :receipt_upload_hdrs do
      resources :receipt_upload_dtls
    end
    match '/item_comments' => 'tbdash_items#item_comments', format: :json, via: :get

    resources :orders, only: [:index]
    resources :order_lines, only: [:index] do
      put 'start_pick', on: :collection
    end
    resources :picks, only: [:index] do
      put 'finish_pick', on: :collection
    end
    match 'binpick_batches/all_batches' => 'binpick_batches#all_batches', via: :get

    resources :binpick_batches, only: [:index, :new, :show, :create, :destroy] do
      put 'picked_complete_batch'
      put 'packed_complete_batch'
      put 'other_new'
      get 'change_batch'
    end

    resources :binpick_bins, only: [:new, :show, :create] do
      put 'deassign'
      put 'release'
      put 'defer'
      put 'change_batch'
    end

    resources :binpick_bin_items, only: [:index, :edit, :update] do
      put 'bin_item_backorder'
      put 'bin_item_bo_reverse'
      put 'autopick_all_orders'
    end

    resources :binpick_orders, only: [:destroy]

    resources :binpick_order_lines, only: [:index] do
      put 'confirm'
      put 'unconfirm'
      get 'line_count', on: :collection
    end

    resources :binpick_replenishments, only: [:index] do
      collection do
        put 'move_it'
        put 'delete_it'
      end
    end

    resources :auto_moved_items, only: [:index] do
        put 'move_it'
    end
    match '/auto_moved_items' => 'auto_moved_items#generate', via: :post
    match '/binpick_batches/:binpick_batch_id/binpick_order_lines' => 'binpick_order_lines#wave_picks', via: :get, as: 'binpick_wave_picks'
    match '/binpick_order_lines/:id/_wave_backorder' => 'binpick_order_lines#wave_backorder', via: :put, as: 'binpick_wave_line_backorder'
    match '/binpick_order_lines/:id/wave_confirm' => 'binpick_order_lines#wave_confirm', via: :put, as: 'binpick_wave_line_confirm'
    match '/binpick_order_lines/:id/wave_unconfirm' => 'binpick_order_lines#wave_unconfirm', via: :put, as: 'binpick_wave_line_unconfirm'

    resources :binpick_emp_sums, only: [:index, :show]

    resources :item_locations, only: [:index, :new, :create]
    resources :whouse_items, only: [:index, :show]

  end
end
