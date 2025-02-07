require "test_helper"

describe DriversController do
  # Note: If any of these tests have names that conflict with either the requirements or your team's decisions, feel empowered to change the test names. For example, if a given test name says "responds with 404" but your team's decision is to respond with redirect, please change the test name.
  let (:driver) {
    Driver.create name: "sample driver", vin: "VH1234SD234F0909", active: true, car_make: "Fiat", car_model: "POP"
  }
  describe "index" do
    it "responds with success when there are many drivers saved" do
      # Arrange
      # Ensure that there is at least one Driver saved
      get driver_path(driver.id)
      # Act/Assert
      must_respond_with :success
    end

    it "responds with success when there are no drivers saved" do
      # Arrange
      # Ensure that there are zero drivers saved
      Driver.destroy_all
      get drivers_path
      # Act/Assert
      must_respond_with :success
    end
  end

  describe "show" do
    it "responds with success when showing an existing valid driver" do
      # Arrange
      # Ensure that there is a driver saved

      # # Act
      get driver_path(driver.id)
      # # Assert
      must_respond_with :success
    end

    it "will redirect with an invalid driver id" do
      # Arrange
      # Ensure that there is an id that points to no driver
      id = -1
      # # Act
      get driver_path(id)
      # # Assert
      must_respond_with :redirect
    end
  end

  describe "new" do
    it "responds with success" do
      get new_driver_path
      must_respond_with :success
    end
  end

  describe "create" do
    it "can create a new driver with valid information accurately, and redirect" do
      # Arrange
      # Set up the form data
      driver_hash = {
        driver: {
          name: "new driver",
          vin: "VH1234SD234F0909",
          active: true,
          car_make: "Toyota",
          car_model: "Sedan",
        },
      }
      # Act-Assert
      # Ensure that there is a change of 1 in Driver.count
      expect {
        post drivers_path, params: driver_hash
      }.must_differ "Driver.count", 1
      # Assert
      # Find the newly created Driver, and check that all its attributes match what was given in the form data
      # Check that the controller redirected the user
      new_driver = Driver.find_by(name: driver_hash[:driver][:name])
      expect(new_driver.vin).must_equal driver_hash[:driver][:vin]
      expect(new_driver.active).must_equal driver_hash[:driver][:active]
      expect(new_driver.car_make).must_equal driver_hash[:driver][:car_make]
      expect(new_driver.car_model).must_equal driver_hash[:driver][:car_model]

      must_respond_with :redirect
      must_redirect_to driver_path(new_driver.id)
    end

    it "does not create a driver if the form data violates Driver validations, and responds with a redirect" do
      # Note: This will not pass until ActiveRecord Validations lesson
      # Arrange
      # Set up the form data so that it violates Driver validations
      driver_hash = {
        driver: {
          name: "",
          vin: "VH1",
          active: true,
          car_make: "Toyota",
          car_model: "Sedan",
        },
      }
      # Act-Assert
      # Ensure that there is no change in Driver.count
      expect {
        post drivers_path, params: driver_hash
      }.must_differ "Driver.count", 0
      # Assert
      # Check that the controller renders successfully
      must_respond_with :success
    end
  end

  describe "edit" do
    it "responds with success when getting the edit page for an existing, valid driver" do
      # Arrange
      # Ensure there is an existing driver saved
      get edit_driver_path(driver.id)

      must_respond_with :success
    end

    it "responds with redirect when getting the edit page for a non-existing driver" do
      # Arrange
      # Ensure there is an invalid id that points to no driver
      id = -1
      get edit_driver_path(id)

      must_respond_with :redirect
      must_redirect_to drivers_path
    end
  end

  describe "update" do
    before do
      Driver.create(name: "sample driver", vin: "VH1234SD234F0909", active: true, car_make: "Fiat", car_model: "POP")
    end

    updated_driver_hash = {
      driver: {
        name: "new driver",
        vin: "VH1234SD234F0909",
        active: false,
        car_make: "Toyota",
        car_model: "Sedan",
      },
    }

    it "can update an existing driver with valid information accurately, and redirect" do
      # Arrange
      # Ensure there is an existing driver saved
      # Assign the existing driver's id to a local variable
      # Set up the form data
      id = Driver.first.id
      # Act-Assert
      # Ensure that there is no change in Driver.count
      expect {
        patch driver_path(id), params: updated_driver_hash
      }.wont_change "Driver.count"

      # Assert
      # Use the local variable of an existing driver's id to find the driver again, and check that its attributes are updated
      # Check that the controller redirected the user
      updated_driver = Driver.find_by(id: id)
      expect(updated_driver.name).must_equal "new driver"
      expect(updated_driver.vin).must_equal "VH1234SD234F0909"
      expect(updated_driver.active).must_equal false
      expect(updated_driver.car_make).must_equal "Toyota"
      expect(updated_driver.car_model).must_equal "Sedan"

      must_respond_with :redirect
    end

    it "will redirect to drivers page if given an invalid id" do
      # Arrange
      # Ensure there is an invalid id that points to no driver
      # Set up the form data
      id = -1
      # Act-Assert
      # Ensure that there is no change in Driver.count
      expect {
        patch driver_path(id), params: updated_driver_hash
      }.wont_change "Driver.count"
      # Assert
      # Check that the controller redirect
      must_respond_with :redirect

      must_redirect_to drivers_path
    end

    it "does not create a driver if the form data violates Driver validations, and responds with a redirect" do
      # Note: This will not pass until ActiveRecord Validations lesson
      # Arrange
      # Ensure there is an existing driver saved
      # Assign the existing driver's id to a local variable
      # Set up the form data so that it violates Driver validations
      invalid_updated_driver_hash = {
        driver: {
          name: "",
          vin: "VH1",
          active: true,
          car_make: "Toyota",
          car_model: "Sedan",
        },
      }
      id = Driver.first.id
      # Act-Assert
      # Ensure that there is no change in Driver.count
      expect {
        patch driver_path(id), params: invalid_updated_driver_hash
      }.must_differ "Driver.count", 0
      # Assert
      # Check that the controller renders successfully
      must_respond_with :success
    end
  end

  describe "destroy" do
    it "destroys the driver instance in db when driver exists, then redirects" do
      # Arrange
      # Ensure there is an existing driver saved
      Driver.create(name: "sample driver", vin: "VH1234SD234F0909", active: true, car_make: "Fiat", car_model: "POP")
      existing_driver_id = Driver.find_by(name: "sample driver").id

      # Act-Assert
      # Ensure that there is a change of -1 in Driver.count
      expect {
        delete driver_path(existing_driver_id)
      }.must_differ "Driver.count", -1

      # Assert
      # Check that the controller redirects
      must_redirect_to drivers_path
    end

    it "does not change the db when the driver does not exist, then responds with redirect" do
      # Arrange
      # Ensure there is an invalid id that points to no driver
      Driver.destroy_all
      invalid_driver_id = 1
      # Act-Assert
      # Ensure that there is no change in Driver.count
      expect {
        delete driver_path(invalid_driver_id)
      }.must_differ "Driver.count", 0
      # Assert
      # Check that the controller responds or redirects with whatever your group decides
      must_redirect_to drivers_path
    end
  end
end
