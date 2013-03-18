#encoding: utf-8
class CompaniesController < ApplicationController

  def index
    @nav_links = nav_links
    @companies = top_companies
  end

  def show
    @name = unslugfy(params[:name]).upcase
    @complaints = Complaint.where(strNomeFantasia: @name)
    @complaints_by_type = Hash[group(@complaints).sort.reverse]
    c = @complaints.first
    @company = {name: c.strNomeFantasia, descricao: c.DescCNAEPrincipal}
    @regions  = regions
    @states   = @complaints.group_by {|comp| comp.UF}
    @solved = @complaints.select{|c| c.atendida? }
    @unsolved = @complaints.reject{|c| c.atendida? }
    @unsolved_by_type = Hash[group(@unsolved).sort.reverse]
    @solved_by_type = Hash[group(@solved).sort.reverse]
    @nav_links = nav_links

    number_of_slices = 5
    max_complaints_count_state = @states.max_by { |state| state.last.length }
    @max_complaints_count = @states[max_complaints_count_state[0]].length
    @slice = (@max_complaints_count/number_of_slices.to_f).ceil

    @complaints_by_fulfillment = complaints_by_fulfillment(@name)
  end

  def search
    companies = Complaint.group_by_company(params[:name])
                         .sort { |a, b| b["value"]["count"] <=> a["value"]["count"] }
    @companies = companies[0, 20].map do |company|
      { name: company["_id"], count: company["value"]["count"].to_i }
    end
    render :index
  end

  def group(complaints)
    # MAP REDUCE MTF! DO YOU USE IT?
    # SAY WHATTTTT??
    # SAY WHAT ONE MORE TIME. I DARE YOU.
    # I DOUBLE DARE YOU!
    complaints.group_by {|compl| compl.CodigoProblema }
  end

  def regions
    { "AC" => ["Acre"                , "A"],
      "AL" => ["Alagoas"             , "B"],
      "AP" => ["Amapá"               , "C"],
      "AM" => ["Amazonas"            , "D"],
      "BA" => ["Bahia"               , "E"],
      "CE" => ["Ceará"               , "F"],
      "DF" => ["Distrito Federal"    , "G"],
      "ES" => ["Espírito Santo"      , "H"],
      "GO" => ["Goiás"               , "I"],
      "MA" => ["Maranhão"            , "J"],
      "MT" => ["Mato Grosso"         , "K"],
      "MS" => ["Mato Grosso do Sul"  , "L"],
      "MG" => ["Minas Gerais"        , "M"],
      "PA" => ["Pará"                , "N"],
      "PB" => ["Paraíba"             , "O"],
      "PR" => ["Paraná"              , "P"],
      "PE" => ["Pernambuco"          , "Q"],
      "PI" => ["Piauí"               , "R"],
      "RJ" => ["Rio de Janeiro"      , "S"],
      "RN" => ["Rio Grande do Norte" , "T"],
      "RS" => ["Rio Grande do Sul"   , "U"],
      "RO" => ["Rondônia"            , "V"],
      "RR" => ["Roraima"             , "W"],
      "SC" => ["Santa Catarina"      , "X"],
      "SP" => ["São Paulo"           , "Y"],
      "SE" => ["Sergipe"             , "Z"],
      "TO" => ["Tocantins"           , "a"]}
  end
  def nav_links
    [
      { name: 'Informações gerais',
        url: '#informacoes-gerais' },
      { name: 'Estatísticas gerais',
        url: '#estatisticas-gerais' },
      { name: 'Ocorrências por mês',
        url: '#ocorrencias-por-mes' },
      { name: 'Solucionados × não solucionados',
        url: '#solucionados-nao-solucionados' },
      { name: 'Reclamações mais frequentes',
        url: '#reclamacoes-mais-frequentes' },
      { name: 'Não solucionados mais frequentes',
        url: '#nao-solucionados-mais-frequentes' },
      { name: 'Solucionados mais frequentes',
        url: '#solucionados-mais-frequentes' },
      { name: 'Reclamações por estados',
        url: '#por-estados' },
      { name: 'Compartilhar',
        url: '#compartilhar' }
    ]
  end

  private
  def complaints_by_fulfillment(name)
    results = {}
    complaints = Complaint.group_by_fulfillment_month_year(name)
    complaints.each do |complaint|
      year, month = complaint['_id'].split('-')
      results[month.to_i] ||= {}
      results[month.to_i][year] = complaint['value']
    end
    results
  end
end
