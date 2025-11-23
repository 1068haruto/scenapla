module ApplicationHelper
  # OGPに使用するFACEBOOKのアプリID
  def facebook_app_id
    ENV["FACEBOOK_APP_ID"] || Rails.application.credentials.dig(:facebook, :app_id)
  end

  # button
  def next_button_post(text, path)
    button_to text, path, class: "btn btn-primary", method: :post, data: { turbo: true }
  end

  def next_button_get(text, path)
    link_to text, path, class: "btn btn-primary", data: { turbo: true }
  end

  def back_button(text, path)
    link_to text, path, class: "btn btn-outline-secondary me-2", data: { turbo: true }
  end

  def edit_button_sm(path)
    link_to "編集", path, class: "btn btn-outline-secondary btn-sm me-2", data: { turbo: true }
  end

  def edit_button(path)
    link_to "編集", path, class: "btn btn-outline-secondary btn-sm me-2", data: { turbo: true }
  end

  def delete_button(path)
    link_to "削除", path, class: "btn btn-outline-danger btn-sm px-1 py-1", data: { turbo_method: :delete }
  end

  def cancel_button(path)
    link_to "キャンセル", path, class: "btn btn-outline-secondary", data: { turbo: true }
  end

  def submit_or_add_button(f, object)
    text = object.persisted? ? "更新" : "追加"

    f.submit text, class: "btn btn-outline-primary me-2"
  end
end
