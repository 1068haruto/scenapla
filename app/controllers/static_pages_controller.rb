class StaticPagesController < ApplicationController
  before_action :authenticate_user!, only: [ :dashboard ]

  # Top
  def index; end

  # Dashboard
  def dashboard; end

  # Terms of Service
  def terms; end

  # Privacy Policy
  def privacy; end
end
