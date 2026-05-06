# frozen_string_literal: true

class DelayedJobDecorator < ApplicationDecorator
  delegate_all

  def display_handler
      s = model.handler.to_s.split('!ruby')[2]
      return s.split(':')[1].split(' ')[0] if s && s.start_with?('/object')
      return s.split(':')[0].split(' ')[1].tr("'",'') + ':' + s.split(':')[2].split(' ')[0] if s && s.start_with?('/class')
      I18n.t('invalid_process')
  end

  def display_last_error
    model.last_error ? model.last_error[/\A.*/] : ''
  end

  def display_run_at
    model.run_at ? model.run_at.strftime('%Y/%m/%d %H:%M (%Z)') : ''
  end

  def display_locked_at
    model.locked_at ? model.locked_at.strftime('%Y/%m/%d %H:%M (%Z)') : ''
  end

  def display_failed_at
    model.failed_at ? model.failed_at.strftime('%Y/%m/%d %H:%M (%Z)') : ''
  end

end