import 'package:flutter/material.dart';
import 'package:shelflife/services/api_service.dart';
import 'package:shelflife/services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotificationsEnabled = true;
  int _defaultReminderDays = 3;
  bool _isSaving = false;

  late ApiService _apiService;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _authService = AuthService();
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final token = await _authService.getToken();

      final response = await _apiService.put(
        'users/me/settings',
        {
          'default_reminder_days': _defaultReminderDays,
          'push_notifications_enabled': _pushNotificationsEnabled,
        },
      );

      print('Settings saved: $response');
      if (response != null && response['status'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save settings')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Push Notifications',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      subtitle: const Text('Enable or disable push notifications'),
                      value: _pushNotificationsEnabled,
                      onChanged: (val) {
                        setState(() {
                          _pushNotificationsEnabled = val;
                        });
                      },
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Default Reminder Days',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        DropdownButton<int>(
                          value: _defaultReminderDays,
                          items: List.generate(7, (index) {
                            final day = index + 1;
                            return DropdownMenuItem<int>(
                              value: day,
                              child: Text(day.toString()),
                            );
                          }),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _defaultReminderDays = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
