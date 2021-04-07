class PostPersisterTaskService < TaskService
  def initialize(options)
    super
    @upload_task = Task.where(:child_task_id => @options[:task].id).first

    raise "No refresh task with child_task_id #{@options[:task].id} is found" if @upload_task.nil?
  end

  def process
    update_source
    self
  end

  private

  def validate_options
    super
    raise("Options must have task key") if @options[:task].blank?
  end

  def update_source
    source = Source.find(@options[:task].source_id)
    @options[:task].status == "ok" ? source.update!(ok_options) : source.update!(error_options)

    Rails.logger.info("Source #{source.id}: refresh finished at #{source.refresh_finished_at}, state: #{source.refresh_state}")
  end

  def ok_options
    {:last_successful_refresh_at => @upload_task.created_at,
     :previous_sha               => @upload_task.output["sha256"],
     :previous_size              => @upload_task.output["tar_size"],
     :refresh_finished_at        => Time.current,
     :last_refresh_message       => refresh_stats_message,
     :refresh_state              => "Done"}
  end

  def error_options
    {:refresh_finished_at  => Time.current,
     :last_refresh_message => @options[:task][:output]["errors"].join("\n"),
     :refresh_state        => "Error"}
  end

  def refresh_stats_message
    message = ""
    @options[:task][:output].fetch("stats", {}).each do |obj, counters|
       hash = counters.select { |key, value| value > 0 }
       next if hash.empty?
       if message != ""
          message += "\n"
       end
       message += "#{obj}: "
       message += hash.map{|k,v| "#{k}=#{v}"}.join(',')
    end
    if message == ""
       message = "No updates"
    end
    message
  end
end
