class ContactsController < ApplicationController
  load_and_authorize_resource :supplier,:except => [:add, :confirmadd, :relation, :deleterelation]
  load_and_authorize_resource :contact, through: :supplier, parent: false,:except => [:add, :confirmadd, :relation, :deleterelation]

  # GET /contacts
  # GET /contacts.json
  def index
    @contacts_grid = initialize_grid(@contacts)
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
  end

  # GET /contacts/new
  def new
    #@contact = Contact.new
  end

  # GET /contacts/1/edit
  def edit
  end

  # POST /contacts
  # POST /contacts.json
  def create
    #@contact = Contact.new(contact_params)

    respond_to do |format|
      if @contact.save
        format.html { redirect_to supplier_contact_path(@supplier,@contact), notice: I18n.t('controller.create_success_notice', model: '联系人')}
        format.json { render action: 'show', status: :created, location: @contact }
      else
        format.html { render action: 'new' }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    respond_to do |format|
      if @contact.update(contact_params)
        format.html { redirect_to supplier_contact_path(@supplier,@contact), notice: I18n.t('controller.update_success_notice', model: '联系人')}
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact.destroy
    respond_to do |format|
      format.html { redirect_to supplier_contacts_path(@supplier) }
      format.json { head :no_content }
    end
  end

  def relation
    @RelationshipId=params[:rid]
    @Rcontacts = Relationship.find(@RelationshipId).contacts
  end

  def add
    @RelationshipId=params[:rid]
    @contacts = Relationship.find(@RelationshipId).supplier.contacts
    render :layout=> false
  end

  def confirmadd
    relationship=Relationship.find(params[:rid])
    relationship.contacts.destroy_all
    contacts=params[:contacts]
    contacts.each do |id|
      contact=Contact.find(id)
      relationship.contacts<<contact
    end
  end

  def deleterelation
    relationship=Relationship.find(params[:rid])
    relationship.contacts.destroy(Contact.find(params[:id]))
    redirect_to relation_contacts_path(:rid=>params[:rid])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      @contact = Contact.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_params
      params.require(:contact).permit(:name, :email, :phone, :desc, :supplier_id)
    end
end
