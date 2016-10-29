#tag Class
Protected Class SendEmail
Inherits Thread
	#tag Event
		Sub Run()
		  // Verify that we have a Mailgun API Key and Domain set.
		  If (MailgunApiKey = "" Or MailgunDomain = "") Then
		    Dim _exception As New RuntimeException
		    _exception.Message = "Missing Mailgun API key and/or Mailgun domain."
		    Error(_exception)
		    Return
		  End If
		  
		  // Verify we have the essential fields necessary to send an email.
		  If (Sender = "" Or Recipient = "") Then
		    Dim _exception As New RuntimeException
		    _exception.Message = "Missing sender and/or recipient information."
		    Error(_exception)
		    Return
		  End If
		  
		  // Create Mailgun URL
		  Dim _url As Text
		  _url = "https://api.mailgun.net/v3/" + MailgunX.MailgunDomain + "/messages"
		  
		  // Create HTTP socket for Mailgun
		  pHTTP = New Xojo.Net.HTTPSocket
		  AddHandler pHTTP.AuthenticationRequired, AddressOf mHTTP_AuthenticationRequired
		  AddHandler pHTTP.Error, AddressOf mHTTP_Error
		  AddHandler pHTTP.PageReceived, AddressOf mHTTP_PageReceived
		  
		  // Create message parameters
		  Dim _msg() As Text
		  _msg.Append("from=")
		  _msg.Append(EncodeURLComponent(Sender).ToText())
		  _msg.Append("&")
		  _msg.Append("to=")
		  _msg.Append(EncodeURLComponent(Recipient).ToText())
		  If (CC <> "") Then
		    _msg.Append("&")
		    _msg.Append("cc=")
		    _msg.Append(EncodeURLComponent(CC).ToText())
		  End If
		  If (BCC <> "") Then
		    _msg.Append("&")
		    _msg.Append("bcc=")
		    _msg.Append(EncodeURLComponent(BCC).ToText())
		  End If
		  _msg.Append("&")
		  _msg.Append("subject=")
		  _msg.Append(EncodeURLComponent(Subject).ToText())
		  If (MessageAsText <> "") Then
		    _msg.Append("&")
		    _msg.Append("text=")
		    _msg.Append(EncodeURLComponent(MessageAsText).ToText())
		  End If
		  If (MessageAsHTML <> "") Then
		    _msg.Append("&")
		    _msg.Append("html=")
		    _msg.Append(EncodeURLComponent(MessageAsHTML).ToText())
		  End If
		  
		  // Set HTTP request content
		  Dim _content As Xojo.Core.MemoryBlock
		  _content = Xojo.Core.TextEncoding.UTF8.ConvertTextToData(Text.Join(_msg, ""))
		  pHTTP.SetRequestContent(_content, "application/x-www-form-urlencoded")
		  
		  // Send HTTP request
		  pHTTP.Send("POST", _url)
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub Constructor()
		  // Set this Mailgun transaction as lowest possible thread priority.
		  me.Priority = 1
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function mHTTP_AuthenticationRequired(Sender As Xojo.Net.HTTPSocket, Realm As Text, ByRef Name As Text, ByRef Password As Text) As Boolean
		  // Set Mailgun API authentication parameters.
		  Name = "api"
		  Password = MailgunX.MailgunApiKey
		  
		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub mHTTP_Error(Sender As Xojo.Net.HTTPSocket, ErrorException As RuntimeException)
		  // Raise Error event.
		  Error(ErrorException)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub mHTTP_PageReceived(Sender As Xojo.Net.HTTPSocket, URL As Text, HTTPStatus As Integer, Content As Xojo.Core.MemoryBlock)
		  // Capture response from Mailgun.
		  Dim _response As Text
		  _response = Xojo.Core.TextEncoding.UTF8.ConvertDataToText(Content)
		  
		  // Convert JSON response to Dictionary
		  Dim _json As Xojo.Core.Dictionary
		  _json = Xojo.Data.ParseJSON(_response)
		  
		  // Raise 'MessageSent' event
		  MessageSent(_json)
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Error(ErrorException As RuntimeException)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event MessageSent(MailgunResponse As Xojo.Core.Dictionary)
	#tag EndHook


	#tag Property, Flags = &h0
		BCC As Text
	#tag EndProperty

	#tag Property, Flags = &h0
		CC As Text
	#tag EndProperty

	#tag Property, Flags = &h0
		MessageAsHTML As Text
	#tag EndProperty

	#tag Property, Flags = &h0
		MessageAsText As Text
	#tag EndProperty

	#tag Property, Flags = &h21
		Private pHTTP As Xojo.Net.HTTPSocket
	#tag EndProperty

	#tag Property, Flags = &h0
		Recipient As Text
	#tag EndProperty

	#tag Property, Flags = &h0
		Sender As Text
	#tag EndProperty

	#tag Property, Flags = &h0
		Subject As Text
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="BCC"
			Group="Behavior"
			Type="Text"
		#tag EndViewProperty
		#tag ViewProperty
			Name="CC"
			Group="Behavior"
			Type="Text"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			Type="Integer"
			EditorType="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MessageAsHTML"
			Group="Behavior"
			Type="Text"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MessageAsText"
			Group="Behavior"
			Type="Text"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
			EditorType="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Priority"
			Visible=true
			Group="Behavior"
			InitialValue="5"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Recipient"
			Group="Behavior"
			Type="Text"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Sender"
			Group="Behavior"
			Type="Text"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StackSize"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Subject"
			Group="Behavior"
			Type="Text"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
			EditorType="String"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
