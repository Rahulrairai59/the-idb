class UserPresenter < Keynote::Presenter
  use_html_5_tags

  presents :user

  delegate :email, :login, to: :user

  def name_link
    link_to(user.name ? user.name : "-no name-", edit_user_path(user)) if user
  end

end
