class PicturePolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end

    def resolve
      scope.joins(dive: :trip).where(trips: { user: user })
    end
  end

  def show?
    record.dive.trip.user == user
  end

  def index?
    record.dive.trip.user == user
  end

  def new?
    true
  end

  def create?
    record.dive.trip.user == user
  end

  def edit?
    record.dive.trip.user == user
  end

  def update?
    record.dive.trip.user == user
  end

  def destroy?
    record.dive.trip.user == user
  end

  def generate_species_details?
    show?
  end
end
