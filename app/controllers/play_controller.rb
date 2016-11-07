class PlayController < ApplicationController

 SYSTRAN_API = "https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=9a384e07-fc6b-441f-a19f-10305a1389fd&input="

 require 'open-uri'
 require 'json'

  def attempt_is_grid_compliant?(attempt, grid)
      #  return true if the atempt is grid compliant
      array_attempt = attempt.upcase.chars
      # array_attempt.all? { |e| grid.include?(e) }
      hash_grid = {}
      hash_attempt = {}
      array_attempt.each do |letter|
        if hash_attempt.key?(letter)
          hash_attempt[letter] += 1
        else
          hash_attempt[letter] = 1
        end
      end
      grid.each do |letter|
        if hash_grid.key?(letter)
          hash_grid[letter] += 1
        else
          hash_grid[letter] = 1
        end
      end
      a = true
      hash_attempt.each do |key, value|
        if hash_grid[key] && ( hash_grid[key] >= hash_attempt[key] )
          true
        else
          a = false
        end
      end
      a
  end



  def translation(attempt)
    attempt_in_systran = open(SYSTRAN_API + attempt).read
    hashi = JSON.parse(attempt_in_systran)
    if hashi["outputs"][0]["output"] == attempt
      nil
    else
      {traduction: hashi["outputs"][0]["output"], nb_characters: hashi["outputs"][0]["nb_characters"]}
    end
  end


  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    translations = translation(attempt)
    if attempt_is_grid_compliant?(attempt, grid) == true && translations
      pts_length = (translations[:nb_characters].to_i / (grid.size)) * 100
      pts_time = (1000 / ((end_time - start_time).to_f))
      { time: end_time - start_time, translation: translations[:traduction] , score: pts_time + pts_length, message: "well done" }
    elsif attempt_is_grid_compliant?(attempt, grid) == true && translations == nil
      { time: end_time - start_time, translation: nil, score: 0, message: "not an english word" }
    elsif attempt_is_grid_compliant?(attempt, grid) == false
      { time: end_time - start_time, translation: nil, score: 0, message: "not in the grid" }
    end
  end


  def game
    @grid = []
    for i in (1..9)
      @grid << ('A'..'Z').to_a[rand(26)]
    end

  end

  def score
    @end_time = Time.now.to_f
    @answer = params[:query]
    # @end_time =params[:time].to_i
    @start_time = params[:starttime].to_i.to_f
    @ingrid = params[:ingrid].split("")
    @result = run_game(@answer.to_s,@ingrid,@start_time,@end_time)
  end

end
