module BrowseHelper

  def model_visibility(model)
    output = "Visible to #{model.visibility.name}"

    if model.group_visible?
      output += " (#{group_link(model.group)})"
    end

    output
  end

  def model_changeability(model)
    output = "Changeable by #{model.changeability.name}"

    if model.group_changeable?
      output += " (#{group_link(model.group)})"
    end

    output
  end
  def model_group(model)
    if model.group
      output = "Model group " + group_link(model.group);
    else 
      output = "No model group"
    end
    output
  end
end
