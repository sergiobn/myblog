class Article < ActiveRecord::Base
	include AASM
	#tabla -> articles
	#campos -> article.title() x ej
	belongs_to :user
	has_many :comments
	has_many :has_categories
	has_many :categories, through: :has_categories

	validates :title, presence: true, uniqueness: true
	validates :body, presence: true, length: { minimum: 20 }
	#before_save :set_visits_count
	after_create :save_categories

	has_attached_file :cover #, styles: { medium: "1280x720", thumb:"800x600"}
	validates_attachment_content_type :cover, content_type: /\Aimage\/.*\Z/
	#validates :username, format: { with: /regex/ }

	#lamda abstaraccion en el segundo parametro
	scope :publicados, ->{ where(state: "published") } #particularidad de raisl seria lo mismo que el comentario posterior
	#def self.publicados
	#	Article.where(state: "published")
	#end
	#ordenar los articulos por fecha de creacion descendiente y solo 10
	scope :ultimos, ->{ order("created_at DESC")}
	

	# esto es un custom setter ( se reconoce con el = y se invoca desde el articlesController desde la linea 
	# ->@article.categories = params[:categories])
	#aunque categories no es un atributo de esta clase
	def categories=(value)
		@categories = value
	end

	def update_visits_count
		if self.visits_count.nil?
			self.update(visits_count: 0)
		else
			self.update(visits_count: self.visits_count + 1)
		end
	end

	aasm column: "state" do
		state :in_draft, initial: true
		state :published

		event :publish do
			transitions from: :in_draft, to: :published
		end

		event :unpublish do
			transitions from: :published, to: :in_draft
		end

	end

	private
	#una vez creado el objeto article creamos la relacion entre articulos y categorias en la tabla intermedia 
	def save_categories
		unless @categories.nil?
			@categories.each do |category_id|
				HasCategory.create(category_id: category_id, article_id: self.id )
			end
		end
	end
	#def set_visits_count
	#	logger.info "##########################################################"
		#self.visits_count = 0
	#end
end
