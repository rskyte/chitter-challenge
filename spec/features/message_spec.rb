feature 'Messages' do

  scenario 'users can post messages' do
    visit '/chat'
    fill_in :message, with: 'Hello World!'
    click_on 'PeepIt'
    expect(page).to have_content 'Hello World!'
  end

  scenario 'messages are displayed in reverse chronological order' do
    visit '/chat'
    send_peep('Hello World!')
    send_peep('Goodbye Cruel World!')
    'Hello World!'.should appear_before 'Goodbye Cruel World!'
  end

  scenario 'messages are timestamped' do
    time = Time.now
    visit '/chat'
    send_peep('Hello World!')
    expect(page).to have_content time.strftime("%b %e, %l:%M %p")
  end

end
