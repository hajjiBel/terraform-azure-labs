# Lab 08 — Passage de count (index) à for_each (clé) sans recréation.
# À supprimer quand tous les états ont été migrés.

moved {
  from = azurerm_public_ip.web[0]
  to   = azurerm_public_ip.web["web-1"]
}

moved {
  from = azurerm_public_ip.web[1]
  to   = azurerm_public_ip.web["web-2"]
}

moved {
  from = azurerm_network_interface.web[0]
  to   = azurerm_network_interface.web["web-1"]
}

moved {
  from = azurerm_network_interface.web[1]
  to   = azurerm_network_interface.web["web-2"]
}

moved {
  from = azurerm_linux_virtual_machine.web[0]
  to   = azurerm_linux_virtual_machine.web["web-1"]
}

moved {
  from = azurerm_linux_virtual_machine.web[1]
  to   = azurerm_linux_virtual_machine.web["web-2"]
}
