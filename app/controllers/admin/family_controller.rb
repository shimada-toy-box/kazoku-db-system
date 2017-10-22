class Admin::FamilyController < Admin::AdminController
  before_action :create_params, only: [:show, :edit, :update]
  def index
    @user_list = User.where(is_family: true)
  end

  def show
    @requests = EmailQueue.where(
        email_type: Settings.email_type.request,
        to_address: @family.contact.email_pc
    )
  end

  def new
    # TODO: user.timestamp発行機能
  end

  def edit
  end

  def update
    if @family.update(family_params) and
       @family.contact.update(contact_params) and
       @family.location.update(location_params) and
       @family.profile_family.update(profile_family_params) and
       @mother.update(mother_params) and
       @father.update(father_params)
      redirect_to edit_admin_family_path(params[:id]), notice: '更新成功'
    else
      redirect_to edit_admin_family_path(params[:id]), alert: '更新失敗'
    end
  end

  def destroy
    @family = User.find(params[:id])
    if @family.destroy
      redirect_to admin_family_index_path, notice: '削除成功'
    else
      redirect_to admin_family_index_path, notice: '削除失敗'
    end
  end

  private

  def create_params
    @family = User.find(params[:id])
    @mother = @family.profile_family&.profile_individuals&.find_by(role: 'mother')
    @father = @family.profile_family&.profile_individuals&.find_by(role: 'father')
  end

  def family_params
    p = params.permit(:name, :kana, :gender)
    p[:gender] = p[:gender].to_i
    p
  end

  def location_params
    params.permit(:address)
  end

  def contact_params
    params.permit(:email_pc, :email_phone, :phone_number)
  end

  def profile_family_params
    p = params.permit(
      :job_style, :first_childbirth_mother_age,
      :married_mother_age, :number_of_children, :child_birthday,
      :has_time_shortening_experience,
      :has_childcare_leave_experience,
      :has_job_change_experience,
      :is_photo_ok, :is_report_ok, :is_male_ok,
      :opinion_or_question
    )
    p[:job_style] = p[:job_style].to_i
    p
  end

  def mother_params
    p = params.permit(
      :birthday_mother, :hometown_mother, :job_domain_mother,
      :company_mother, :career_mother, :is_abroad_mother
    )
    # p[:has_experience_abroad] = p[:is_abroad_mother]
    individual_params(p,
      :birthday_mother, :job_domain_mother,
      :hometown_mother, :company_mother,
      :career_mother, :is_abroad_mother
    )
  end

  def father_params
    p = params.permit(
      :birthday_father, :hometown_father, :job_domain_father,
      :company_father, :career_father, :is_abroad_father
    )
    individual_params(p,
      :birthday_father, :job_domain_father,
      :hometown_father, :company_father,
      :career_father, :is_abroad_father
    )
  end

  def individual_params(p, birthday, job_domain, hometown,
                        company, career, is_abroad)
    # TODO: 指定フォーマットに変換
    p[:birthday] = p[birthday]
    p[:job_domain] = JobDomain.find(p[job_domain])
    p[:hometown] = p[hometown]
    p[:company] = p[company]
    p[:career] = p[career]
    p[:has_experience_abroad] = p[is_abroad]

    p.delete(birthday)
    p.delete(job_domain)
    p.delete(hometown)
    p.delete(company)
    p.delete(career)
    p.delete(is_abroad)
    p
  end

end
