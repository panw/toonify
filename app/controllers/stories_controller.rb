class StoriesController < ApplicationController
  before_action :set_story, only: [:show, :edit, :update, :destroy]

  # GET /stories
  # GET /stories.json
  def index
    @stories = Story.all
  end

  # GET /stories/1
  # GET /stories/1.json
  def show
  end

  # GET /stories/new
  def new
    @story = Story.new
  end

  # GET /stories/1/edit
  def edit
  end

  # POST /stories
  # POST /stories.json
  def create
    image = params[:story][:image].tempfile.path
    system("echo '###Script Running###'")
    system("sh #{Rails.root}/lib/cartoonify.sh #{image} #{Rails.root}/public/temp.jpg")
    # @story.image = system("echo #{Rails.root}/public/temp.jpg}")
    system("mv -f #{Rails.root}/public/temp.jpg #{image}")
    @story = Story.new(story_params)
    puts @story.to_yaml
    respond_to do |format|
      if @story.save
        format.html { redirect_to @story, notice: 'Story was successfully created.' }
        format.json { render action: 'show', status: :created, location: @story }
      else
        format.html { render action: 'new' }
        format.json { render json: @story.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stories/1
  # PATCH/PUT /stories/1.json
  def update
    respond_to do |format|
      if @story.update(story_params)
        puts "????? Story Params Image ?????"
        image = params[:story][:image].tempfile.path
        system("echo '#{image}'")
        system("sh #{Rails.root}/lib/cartoonify.sh #{image} #{Rails.root}/public/temp.jpg")
        # system("#{params[:story][:image].tempfile}")
        system("mv -f #{Rails.root}/public/temp.jpg #{params[:story][:image].tempfile.path}")
        format.html { redirect_to @story, notice: 'Story was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @story.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stories/1
  # DELETE /stories/1.json
  def destroy
    @story.destroy
    respond_to do |format|
      format.html { redirect_to stories_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_story
      @story = Story.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def story_params
      params.require(:story).permit(:title, :image)
    end
end
