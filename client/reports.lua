
TriggerServerEvent('nex:Admin:Reports:init')

----------------------------------------------------------------------------------------

RegisterNetEvent('nex:Admin:Reports:CreateReport')
AddEventHandler('nex:Admin:Reports:CreateReport', function(message)
    NEX.UI.SendAlert('error', 'Reporte', 'Se esta procesando y enviando su reporte, por favor espere.', 4000, {})

    if Config.UseSreenshotBasic then
        TriggerEvent('nex:Admin:Reports:Screenshot', function(imageUrl)
            NEX.TriggerServerCallback('nex:Admin:Reports:SendReport', function(success)
                if success then
                    NEX.UI.SendAlert('success', 'Reporte', 'Su reporte ha sido enviado.', 4000, {})
                else
                    NEX.UI.SendAlert('error', 'Reporte', 'Por favor espere o compruebe su mensaje.', 4000, {})
                end
            end, message, imageUrl)
        end)
    else
        NEX.TriggerServerCallback('nex:Admin:Reports:SendReport', function(success)
            if success then
                NEX.UI.SendAlert('success', 'Reporte', 'Su reporte ha sido enviado.', 4000, {})
            else
                NEX.UI.SendAlert('error', 'Reporte', 'Por favor espere o compruebe su mensaje.', 4000, {})
            end
        end, message, nil)
    end
end)

RegisterNetEvent('nex:Admin:Reports:RequetsScreenshot')
AddEventHandler('nex:Admin:Reports:RequetsScreenshot', function(adminSource)
    TriggerEvent('nex:Admin:Reports:Screenshot', function(imgUrl)
        NEX.TriggerServerCallback('nex:Admin:Reports:RequetsScreenshot', function(success)
            if success then
                TriggerServerEvent('nex:Admin:Reports:SuccessScreenshot', adminSource)
            end
        end, adminSource, imgUrl)
    end)
end)

RegisterNetEvent('nex:Admin:Reports:Screenshot')
AddEventHandler('nex:Admin:Reports:Screenshot', function(cb)

    exports['screenshot-basic']:requestScreenshotUpload('https://api.imgur.com/3/image', 'imgur', {
        headers = {
            ['authorization'] = string.format('Client-ID %s', Config.clientIdForImgur),
            ['content-type'] = 'multipart/form-data'
        }
    }, function(data)
        local data = json.decode(data).data.link
        cb(data)
    end)

end)