class AppUrl {
  // Development
  static const String baseUrl = "https://pollchat.myappsdevelopment.co.in";
  // Production
  static const String baseUrl2 = "http://103.211.202.117:8080";
  static const String loginUrl = "$baseUrl/api/v1/user/login";
  static const String signupUrl = "$baseUrl/api/v1/user/create";
  static const String activateUrl = "$baseUrl/api/v1/activateuser";
  static const String updateProfile = "$baseUrl/api/v1/user/editProfile/";
  static const String editProfilePhoto =
      "$baseUrl/api/v1/user/editProfilePhoto/";
  static const String userProfile = "$baseUrl/api/v1/getprofile";
  static const String getallusers = "$baseUrl/api/v1/user/";
  static const String createPoll = "$baseUrl/api/v1/poll/create";
  static const String updatePoll = "$baseUrl/api/v1/poll/update/";
  static const String allPollByUser = "$baseUrl/api/v1/getAllPollByUser";
  static const String allPolls = "$baseUrl/api/v1/poll/polls/";
  static const String everyonepolls = "$baseUrl/api/v1/poll/everyonepolls/";
  static const String savedpolls = "$baseUrl/api/v1/saved/polls";
  static const String pinnedPolls = "$baseUrl/api/v1/poll/pin/get/";
  static const String resetPoll = "$baseUrl/api/v1/poll/reset/vote/";
  static const String editPoll = "$baseUrl/api/v1/poll/edit/";
  static const String sendVote = "$baseUrl/api/v1/poll/vote/";
  static const String likeDislike = "$baseUrl/api/v1/likeDislike/";
  static const String savepoll = "$baseUrl/api/v1/saved/poll/";
  static const String comment = "$baseUrl/api/v1/comment/";
  static const String actioncomment = "$baseUrl/api/v1/comment/action/";
  static const String allMusic = "$baseUrl/api/v1/music/";
  static const String createPost = "$baseUrl/api/v1/action/create/";
  static const String createStoryPost = "$baseUrl/api/v1/moment/create/";

  static String getPollByUserId({required String id}) {
    return "$baseUrl/api/v1/poll/polls/$id";
  }

  static String pollSendVote({required String id}) {
    return "$baseUrl/api/v1/poll/vote/$id";
  }

  static String deletePollById({required String pollId}) {
    return "$baseUrl/api/v1/deletePollById/$pollId";
  }

  static String verifyotpId() {
    return "$baseUrl/api/v1/user/verifyOtp/";
  }

  static String createProfileId({required String id}) {
    return "$baseUrl/api/v1/user/createProfile/$id";
  }

  static String fillProfileUri({required String mobile}) {
    return "$baseUrl/user/fill-profile/$mobile";
  }

  static String getUser({required String id}) {
    return "$baseUrl/api/v1/user/$id";
  }

  static String updatePollLikeCount({required String pollId}) {
    return "$baseUrl/poll/update-like-count/$pollId";
  }

  static String updatePollDisLikeCount({required String pollId}) {
    return "$baseUrl/poll/update-dislike-count/$pollId";
  }

  static String addPollComment({required String pollId}) {
    return "$baseUrl/poll/update-comment-count/$pollId";
  }

  static String addPollPinnedStatus({required String pollId}) {
    return "$baseUrl/poll/update-pinned-status/$pollId";
  }
}
