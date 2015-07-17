class CompareMoreController < ApplicationController
  def compare_more
    @here = 8
    @researchers = session[:id]
    if @researchers 
      #Buscando as recomendações(apenas para exibição do menu principal)...
      @affins = Affin.where("pesquisador1_id = ?", @researchers).order('value DESC')
      @corals = Corals.where("pesquisador1_id = ?", @researchers).order('value DESC')
    end
    @text = session[:text]
    if (@text != nil)
      @institutions_names = @text.split(',')
      for i in 0..(@institutions_names.length - 1)
	@institutions_names[i] = @institutions_names[i].lstrip
      end
      @institution_researchers = []
      for i in 0..(@institutions_names.length - 1)
	@researcher = Pesquisador.select("id")
	  .where("instituicao LIKE ?", @institutions_names[i]).map(&:id)
	@institution_researchers.push(@researcher)
      end
      @matrix = []
      for i in 0..(@institutions_names.length - 1)
	@array = []
	@total = 0
	for j in 0..(@institutions_names.length - 1)
	  @num_pub = Link.select("count(*) as num")
	    .where("source in (?) AND target in (?)",  @institution_researchers[i], @institution_researchers[j])
	    .map(&:num)
	  @total = @num_pub.inject(:+)
	  if (@total != nil)
	    @array.push(@total)
	  else
	    @array.push(0)
	  end
	end
	@matrix.push(@array)
      end
      respond_to do |format|
	format.html
	format.json {
	  render :json => {
	    :matrix => @matrix,
	    :names => @institutions_names
	  }
	}
      end
    end
  end
  def create
    session[:text] = params[:search]
    redirect_to url_for(:action => :compare_more)
  end
end
