module SpreadSheet
  require 'google/apis/sheets_v4'
  require 'googleauth'
  require 'googleauth/stores/file_token_store'
  require 'fileutils'

  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
  APPLICATION_NAME = 'Fetch from manma\'s spread sheet'
  CLIENT_SECRETS_PATH = 'client_secret.json'
  CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                               "sheets.googleapis.com-ruby-quickstart.yaml")
  SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY

  ##
  # Ensure valid credentials, either by restoring from the saved credentials
  # files or intitiating an OAuth2 authorization. If authorization is required,
  # the user's default browser will be launched to approve the request.
  #
  # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
  def self.authorize
    FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

    client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)
    if credentials.nil?
      url = authorizer.get_authorization_url(base_url: OOB_URI)
      # TODO: リフレッシュトークンの入力
      # TODO: リフレッシュトークンの有無で処理を分岐して認証する
      puts "Open the following URL in the browser and enter the " +
               "resulting code after authorization"
      puts url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
          user_id: user_id, code: code, base_url: OOB_URI)
    end
    credentials
  end

  # 認証を行う処理
  # TODO: authorizeの有無で処理を分岐する
  def self.fetch_spread_sheet
    # Initialize the API
    service = Google::Apis::SheetsV4::SheetsService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize

    # Prints the names and majors of students in a sample spreadsheet:
    # https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit
    spreadsheet_id = '13z-3YJLbz7YPLL6a2nM-ub1eT-JGIb0tZZ4ggq0jw3o'
    sheet_name = 'フォームの回答 1'
    range = "#{sheet_name}!A2:AD"
    response = service.get_spreadsheet_values(spreadsheet_id, range)
    puts 'No data found.' if response.values.empty?
    response.values.each do |row|
      # Print columns A and E, which correspond to indices 0 and 4.
      puts "#{row[1]}"
    end
  end

end