module BrowseHelper

  def model_visibility(model)
    output = "Visible by #{model.visibility.name}"

    if model.group_visible?
      output += "(#{group_link(model.group)} group)"
    end

    output
  end

  def model_changeability(model)
    output = "Changeable by #{model.visibility.name}"

    if model.group_changeable?
      output += "(#{group_link(model.group)} group)"
    end

    output
  end
end
