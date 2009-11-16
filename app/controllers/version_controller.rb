class VersionController < ApplicationController
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
      NodeVersion.create(:nlmodel_id => @model.id,
                         :person_id => @person.id,
                         :node_contents => version.file_contents,
                         :note => "Reverted to older version")
    if @new_version.save
      flash[:notice] = "Model was reverted to an older version"
    else
      flash[:notice] = "Error reverting the model; nothing was changed."
    end

    redirect_to :back
  end

  def compare_versions
    @version_1 = NodeVersion.find(params[:compare_1])
    @version_2 = NodeVersion.find(params[:compare_2])

    if @version_1 == @version_2
      flash[:notice] = "You cannot compare a version with itself!"
      redirect_to :back
      return
    end

    @comparison_results = { }
    @comparison_results['info_tab'] =
      diff_as_string(@version_1.info_tab, @version_2.info_tab)

    # @comparison_results['gui_tab'] =
    #diff_as_string(@version_1.gui_tab, @version_2.gui_tab)

    # @comparison_results['procedures_tab'] =
    # diff_as_string(@version_1.procedures_tab, @version_2.procedures_tab)
  end

  private
  def diff_as_string(data_old, data_new, format=:unified, context_lines=1)
    data_old = data_old.split(/\n/).map! { |e| e.chomp}
    data_new = data_new.split(/\n/).map! { |e| e.chomp}

    output = ''
    diffs = Diff::LCS.diff(data_old,data_new)

    return output if diffs.empty?
    oldhunk = hunk = nil
    file_length_difference = 0

    diffs.each do |piece|
      begin
        hunk = Diff::LCS::Hunk.new(data_old, data_new, piece, context_lines,
                                   file_length_difference)
        file_length_difference = hunk.file_length_difference
        next unless oldhunk

        if (context_lines > 0) and hunk.overlaps?(oldhunk)
          hunk.unshift(oldhunk)
        else
          output << oldhunk.diff(format)
        end
      ensure
        oldhunk = hunk
        output << "\n"
      end
    end

    output << oldhunk.diff(format) << "\n"
  end



end
