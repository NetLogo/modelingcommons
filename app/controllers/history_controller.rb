# Controller that shows the history of a model

class HistoryController < ApplicationController

  prepend_before_filter :get_model_from_id_param, :except => [:compare_versions]

  def revert_model
    # Make sure that we got an older version
    version_id = params[:version]
    if version_id.blank?
      flash[:notice] = "Sorry, but you must specify a version to which you want to revert."
      redirect_to :back
      return
    end

    # Check that we're not reverting to the latest version!
    version = NodeVersion.find(version_id)
    if version == @model.current_version
      flash[:notice] = "That is already the current version!"
      redirect_to :back
      return
    end

    @new_version =
      NodeVersion.create(:node_id => @model.id,
                         :person_id => @person.id,
                         :contents => version.contents,
                         :description => "Reverted to older version")
    if @new_version.save
      flash[:notice] = "Model was reverted to an older version"
    else
      flash[:notice] = "Error reverting the model; nothing was changed."
    end

    redirect_to :controller => :browse, :action => :one_model, :id => @model.id, :anchor => :history
  end

  def compare_versions
    if params[:compare_1].blank? or params[:compare_2].blank?
      flash[:notice] = "You must select versions in order to compare them."
      redirect_to :back
      return
    end

    earlier_version = NodeVersion.find(params[:compare_1])
    later_version = NodeVersion.find(params[:compare_2])

    @model = earlier_version.node

    if earlier_version == later_version
      flash[:notice] = "You cannot compare a version with itself!"
      redirect_to :controller => :browse, :action => :one_model, :id => @model.id, :anchor => 'browse_history'
      return
    end

    @comparison_results = {
      'info_tab' => diff_as_string(earlier_version.info_tab, later_version.info_tab),
      'procedures_tab' => diff_as_string(earlier_version.procedures_tab, later_version.procedures_tab)
    }
  end

  private
  def diff_as_string(data_old, data_new)
    data_old = data_old.split(/\n/).map! { |line| line.chomp}
    data_new = data_new.split(/\n/).map! { |line| line.chomp}

    output = ''
    diffs = Diff::LCS.diff(data_old,data_new)

    return output if diffs.empty?
    oldhunk = hunk = nil
    file_length_difference = 0

    diffs.each do |piece|
      begin
        hunk = Diff::LCS::Hunk.new(data_old, data_new, piece, 1, file_length_difference)
        file_length_difference = hunk.file_length_difference
        next unless oldhunk

        if hunk.overlaps?(oldhunk)
          hunk.unshift(oldhunk)
        else
          output << oldhunk.diff(:unified)
        end
      ensure
        oldhunk = hunk
        output << "\n"
      end
    end

    output << oldhunk.diff(:unified) << "\n"
  end



end
