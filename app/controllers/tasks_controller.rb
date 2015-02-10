class TasksController < ApplicationController
  load_and_authorize_resource :task

  def index
    @tasks_grid = initialize_grid(@tasks, include: [:user])
  end
  

  # def show
  #   respond_with(@task)
  # end

  # def new
  #   @task = Task.new
  #   respond_with(@task)
  # end

  # def edit
  # end

  # def create
  #   @task = Task.new(task_params)
  #   @task.save
  #   respond_with(@task)
  # end

  # def update
  #   @task.update(task_params)
  #   respond_with(@task)
  # end

  # def destroy
  #   @task.destroy
  #   respond_with(@task)
  # end

  # private
  #   def set_task
  #     @task = Task.find(params[:id])
  #   end

  #   def task_params
  #     params[:task]
  #   end
end
