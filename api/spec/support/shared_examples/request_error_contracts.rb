RSpec.shared_examples 'error object response' do |status:, code:, message:|
  it "returns #{status} with standardized error object" do
    expect(response).to have_http_status(status)
    expect(JSON.parse(response.body)).to include(
      'error' => { 'code' => code, 'message' => message }
    )
  end
end

RSpec.shared_examples 'unauthorized response contract' do
  it_behaves_like 'error object response',
    status: :unauthorized,
    code: 'unauthorized',
    message: 'Unauthorized'
end
