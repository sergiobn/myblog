class ArticlesController < ApplicationController
	before_action :authenticate_user!, except:[:show,:index]
	before_action :set_article, except:[:index,:new,:create]
	before_action :authenticate_editor!, only: [:new,:create,:update]
	before_action :authenticate_admin!, only: [:destroy,:publish]
	#GET /articles
	def index
		#Obtiene todos los registros de la tabla
		#@articles = Article.all #sin @ es inaccesible para la vista
		#Mostrar solo los articulos publicados esto es gracias a ASSM
		#@articles = Article.published #usando AASM la maquina de estadps
		#usando scope
		@articles = Article.paginate(page: params[:page],per_page:9).publicados.ultimos
	end
	#GET /articles/:id
	def show
		@article.update_visits_count
		@comment = Comment.new
	end
	#GET /articles/new
	def new
		@article = Article.new #no se crea pero se reserva la memoria y no esta en la base de datos todavia
		@categories = Category.all
	end
	#POST /articles ->create
	def create
		@article = current_user.articles.new(article_params)
		@article.categories = params[:categories]
		if @article.save
			redirect_to @article
		else
			render :new
		end
	end

	def edit
	end
	#DELETE /articles/:id
	def destroy
		@article.destroy #destroy elimina el objeto de la base de datos
		redirect_to articles_path
	end
	#PUT /articles/:id -> update
	def update
		if @article.update(article_params)
			redirect_to @article
		else
			render :edit
		end
	end

	def publish
		@article.publish!
		redirect_to @article
	end

	private

	def set_article
		@article = Article.find(params[:id])
	end

	def validate_user
		redirect_to new_user_session_path, notice:"Necesitas iniciar sesión"
	end

	def article_params
		params.require(:article).permit(:title,:body,:cover,:categories,:markup_body)
	end

end
